local Types = require "../../Types"

local SpecialKey = require "./SpecialKey"

local bindValueToAttribute = require "../bindValueToAttribute"

local keyCache = {}

local function AttributeOut(attribute: string): Types.SpecialKey<"AttributeOut">
	local key = keyCache[attribute]

	if not key then
		key = SpecialKey "AttributeOut" {
			stage = "observer",
			apply = function(
				scope: Types.Scope,
				applyTo: Instance,
				value: Types.Value<any>
			)
				bindValueToAttribute(scope, value, applyTo, attribute)
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return AttributeOut
