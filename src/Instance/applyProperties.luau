local package = script.Parent.Parent

local Types = require(package.Types)

local Parent = require(package.Instance.Keys._Parent)
local castToState = require(package.State.castToState)
local observe = require(package.Graph.observe)
local peek = require(package.State.peek)
local sortKeys = require(package.Instance.Keys.sortKeys)

local kindof = require(package.Utility.kindOf)
local typeof = require(package.Utility.typeOf)

local function setProperty(instance: Instance, property: string, value: any)
	local success, err = pcall(function()
		(instance :: any)[property] = value
	end)

	if not success then
		warn(err, value)
	end
end

local function applyProperty(
	instance: Instance,
	property: string,
	value: Types.UsedAs<any>
)
	if castToState(value) then
		observe(value, function(new)
			setProperty(instance, property, new)
		end)
	end

	setProperty(instance, property, peek(value))
end

local function applyProperties(
	scope: Types.Scope,
	instance: Instance,
	props: Types.Properties
)
	props = table.clone(props)

	local specialKeys: { Types.SpecialKey } = {}

	props[Parent] = props.Parent
	props.Parent = nil

	for key, value in props do
		local keyType = typeof(key)

		if keyType == 'string' then
			applyProperty(instance, key, value)
		elseif kindof(key) == 'key' then
			table.insert(specialKeys, key)
		end
	end

	table.sort(specialKeys, sortKeys)

	for _, key in specialKeys do
		key.apply(scope, instance, props[key])
	end

	if props.Parent then
		applyProperty(instance, 'Parent', props.Parent)
	end
end

return applyProperties
