local calc = require "../core-calc/types"
local instances = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local peek = require "../core-use/peek"

local observe_immediate = require "../core-graph/observe_immediate"

local parse_error = require "../core-logging/parse_error"

local Parent = require "./keys/Parent"

local sort_keys = require "./keys/sort_keys"
local xtypeof = require "../xtypeof"

local function raw_set_property(instance: Instance, property: string, value: any)
	instance[property] = value
end

local function test_property_assignable(instance: Instance, property: string)
	instance[property] = instance[property]
end

local function set_property(instance: Instance, property: string, value: any)
	local success, err = xpcall(raw_set_property, parse_error, instance, property, value)

	if success then
		return
	end

	if pcall(test_property_assignable, instance, property) == false then
		External.log_error_nonfatal(
			instances.property_cannot_assign,
			nil,
			instance.ClassName,
			property
		)

		return
	end

	local given_type = typeof(value)
	local expected_type = typeof(instance[property])

	if given_type == expected_type then
		External.log_error_nonfatal(instances.property_assign_error, err)
	else
		External.log_error_nonfatal(
			instances.property_invalid_type,
			nil,
			instance.ClassName,
			property,
			expected_type,
			given_type
		)
	end
end

local function apply_property(
	scope: memory.Scope,
	instance: Instance,
	property: string,
	value: calc.UsedAs<any>
)
	observe_immediate(scope, value, function()
		set_property(instance, property, peek(value))
	end)
end

local function apply_properties(
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
			apply_property(scope, instance, key, value)
		elseif key_type == "SpecialKey" then
			table.insert(special_keys, key)
		else
			External.log_error(instances.invalid_key_type, nil, key_type)
		end
	end

	table.sort(special_keys, sort_keys)

	for _, key: instances.SpecialKey in special_keys do
		key.apply(scope, instance, n_properties[key])
	end
end

return apply_properties
