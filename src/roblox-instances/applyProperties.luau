local calc = require "../core-calc/types"
local instances = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local Parent = require "./keys/Parent"
local kindof = require "../kindof"
local observe = require "../core-graph/observe"
local parseError = require "../core-logging/parseError"
local peek = require "../core-use/peek"
local sortKeys = require "./keys/sortKeys"
local xtypeof = require "../xtypeof"

local function rawSetProperty(instance: Instance, property: string, value: any)
	instance[property] = value
end

local function testPropertyAssignable(instance: Instance, property: string)
	instance[property] = instance[property]
end

local function setProperty(instance: Instance, property: string, value: any)
	local success, err = xpcall(rawSetProperty, parseError, instance, property, value)

	if success then
		return
	end

	if pcall(testPropertyAssignable, instance, property) == false then
		External.logErrorNonFatal(
			instances.propertyCannotAssign,
			nil,
			instance.ClassName,
			property
		)

		return
	end

	local given_type = typeof(value)
	local expected_type = typeof(instance[property])

	if given_type == expected_type then
		External.logErrorNonFatal(instances.propertyAssignError, err)
	else
		External.logErrorNonFatal(
			instances.propertyInvalidType,
			nil,
			instance.ClassName,
			property,
			expected_type,
			given_type
		)
	end
end

local function applyProperty(
	scope: memory.Scope,
	instance: Instance,
	property: string,
	value: calc.UsedAs<any>
)
	observe(scope, value, function()
		setProperty(instance, property, peek(value))
	end, true)
end

local function applyProperties(
	scope: memory.Scope,
	instance: Instance,
	properties: instances.Properties
)
	local n_properties = table.clone(properties)

	n_properties[Parent] = n_properties.Parent
	n_properties.Parent = nil

	local special_keys = {}

	for key, value in n_properties do
		local key_type = xtypeof(key)

		if key_type == "string" then
			applyProperty(scope, instance, key, value)
		elseif kindof(key) == "key" then
			table.insert(special_keys, key)
		end
	end

	table.sort(special_keys, sortKeys)

	for _, key: instances.SpecialKey in special_keys do
		key.apply(scope, instance, n_properties[key])
	end
end

return applyProperties
