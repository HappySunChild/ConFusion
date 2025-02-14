local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Observer = require(package.Graph.Observer)

local Parent = require(package.Instance.Keys._Parent)
local castToState = require(package.State.castToState)
local peek = require(package.State.peek)
local sortKeys = require(package.Instance.Keys.sortKeys)

local kindof = require(package.Utility.kindOf)
local typeof = require(package.Utility.typeOf)

local function setProperty(instance: Instance, property: string, value: any)
	local success, err = pcall(function()
		(instance :: any)[property] = value
	end)

	if not success then
		warn(err)
	end
end

local function applyProperty(scope: Types.Scope, instance: Instance, property: string, value: Types.UsedAs<any>)
	if castToState(value) then
		Observer(scope, value):onBind(function()
			setProperty(instance, property, peek(value))
		end)

		return
	end

	setProperty(instance, property, value)
end

local function applyProperties(scope: Types.Scope, instance: Instance, props: Types.Properties)
	props = table.clone(props)

	local specialKeys: { Types.SpecialKey } = {}

	props[Parent] = props.Parent
	props.Parent = nil

	for key, value in props do
		local keyType = typeof(key)

		if keyType == 'string' then
			applyProperty(scope, instance, key, value)
		elseif kindof(key) == 'key' then
			table.insert(specialKeys, key)
		end
	end

	table.sort(specialKeys, sortKeys)

	for _, key in specialKeys do
		print(key[Symbols.Type])

		key.apply(scope, instance, props[key])
	end

	if props.Parent then
		applyProperty(scope, instance, 'Parent', props.Parent)
	end
end

return applyProperties
