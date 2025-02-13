local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Types = require(package.Types)

local Observer = require(package.Graph.Observer)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)
local sortKeys = require(script.Parent.sortKeys)

local function setProperty(instance: Instance, property: string, value: any)
	local success, err = pcall(function()
		instance[property] = value
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
	local specialKeys: { Types.SpecialKey } = {}

	for key, value in props do
		local keyType = Types.of(key)

		if keyType == 'string' and key ~= 'Parent' then
			applyProperty(scope, instance, key, value)
		elseif Kinds.of(key) == Kinds.Key then
			table.insert(specialKeys, key)
		end
	end

	if props.Parent then
		applyProperty(scope, instance, 'Parent', props.Parent)
	end

	table.sort(specialKeys, sortKeys)

	for _, key in specialKeys do
		key.apply(scope, instance, props[key])
	end
end

return applyProperties
