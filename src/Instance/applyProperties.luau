local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local Parent = require(package.Instance.Keys._Parent)
local sortKeys = require(package.Instance.Keys.sortKeys)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local Observer = require(package.Graph.Observer)

local parseError = require(package.Logging.parseError)

local xkindof = require(package.Utility.xkindof)
local xtypeof = require(package.Utility.xtypeof)

local function rawSetProperty(instance: Instance, property: string, value: any)
	instance[property] = value
end

local function testProperty(instance: Instance, property: string)
	instance[property] = instance[property]
end

local function setProperty(instance: Instance, property: string, value: any)
	local success, err = xpcall(rawSetProperty, parseError, instance, property, value)

	if not success then
		if not pcall(testProperty, instance, property) then
			External.logErrorNonFatal(
				"propertyCannotAssign",
				nil,
				instance.ClassName,
				property
			)
		else
			local givenType = typeof(value)
			local expectedType = typeof(instance[property])

			if givenType == expectedType then
				External.logErrorNonFatal("propertyAssignError", err)
			else
				External.logErrorNonFatal(
					"propertyInvalidType",
					nil,
					instance.ClassName,
					property,
					expectedType,
					givenType
				)
			end
		end
	end
end

local function applyProperty(
	scope: Types.Scope,
	instance: Instance,
	property: string,
	value: Types.UsedAs<any>
)
	if castToState(value) then
		Observer(scope, value):onBind(function()
			setProperty(instance, property, peek(value))
		end)

		return
	end

	setProperty(instance, property, value)
end

local function applyProperties<T>(
	scope: Types.Scope<T>,
	instance: Instance,
	props: Types.Properties
)
	props = table.clone(props)

	local specialKeys: { Types.SpecialKey<any> } = {}

	props[Parent] = props.Parent
	props.Parent = nil

	for key, value in props do
		local keyType = xtypeof(key)

		if keyType == "string" then
			applyProperty(scope, instance, key, value)
		elseif xkindof(key) == "key" then
			table.insert(specialKeys, key)
		end
	end

	table.sort(specialKeys, sortKeys)

	for _, key in specialKeys do
		key.apply(scope, instance, props[key])
	end
end

return applyProperties
