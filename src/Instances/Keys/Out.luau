local External = require "../../External"
local Types = require "../../Types"

local xtypeof = require "../../Utility/xtypeof"

local SpecialKey = require "./SpecialKey"

-- local bindValueToProperty = require "../bindValueToProperty"

local function bindValueToProperty(
	scope: Types.Scope,
	value: Types.Value<unknown>,
	instance: Instance,
	property: string
)
	if xtypeof(value) ~= "Value" then
		External.logError("expectedType", nil, "Value", typeof(value))
	end

	local ok, event = pcall(instance.GetPropertyChangedSignal, instance, property)

	if not ok then
		External.logError(
			"cannotConnectChange",
			nil,
			instance.ClassName,
			tostring(property)
		)
	end

	value:set((instance :: any)[property])

	table.insert(
		scope,
		event:Connect(function()
			value:set((instance :: any)[property])
		end)
	)
end

local keyCache = {}

local function Out(property: string): Types.SpecialKey<"Out">
	local key = keyCache[property]

	if not key then
		key = SpecialKey "Out" {
			stage = "observer",
			apply = function(
				scope: Types.Scope,
				applyTo: Instance,
				value: Types.Value<unknown>
			)
				bindValueToProperty(scope, value, applyTo, property)
			end,
		}

		keyCache[property] = key
	end

	return key
end

return Out
