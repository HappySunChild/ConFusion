local Types = require "../../Types"

local SpecialKey = require "./SpecialKey"

local bindValueToProperty = require "../bindValueToProperty"

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
