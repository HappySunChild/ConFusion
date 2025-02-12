local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Types = require(package.Types)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)
local sortKeys = require(script.Parent.sortKeys)

local cache = {}

local function getDefaultProperty(className: string, property: string)
	local classCache = cache[className]

	if not classCache then
		classCache = Instance.new(className)
		cache[className] = classCache
	end

	local success, value = pcall(function()
		return classCache[property]
	end)

	if success then
		return value
	end
end

local function setProperty(instance: Instance, property: string, value: any)
	if value == nil then
		value = getDefaultProperty(instance.ClassName, property)
	end

	local success, err = pcall(function()
		instance[property] = value
	end)

	if not success then
		warn(err, property, value)
	end
end

local function applyProperty(instance: Instance, property: string, value: Types.UsedAs<any>)
	if castToState(value) then
		setProperty(instance, property, peek(value))

		value:onChange(function(new)
			setProperty(instance, property, new)
		end)

		return
	end

	setProperty(instance, property, value)
end

local function applyProperties(instance: Instance, props: Types.Properties)
	local specialKeys = {}

	for key, value in props do
		local keyType = Types.of(key)

		if keyType == 'string' and key ~= 'Parent' then
			applyProperty(instance, key, value)
		elseif Kinds.of(key) == Kinds.Key then
			table.insert(specialKeys, key)
		end
	end

	if props.Parent then
		applyProperty(instance, 'Parent', props.Parent)
	end

	table.sort(specialKeys, sortKeys)

	for _, key in specialKeys do
		key.apply(instance, props[key])
	end
end

return applyProperties
