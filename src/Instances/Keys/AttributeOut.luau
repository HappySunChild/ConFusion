local External = require "../../External"
local Types = require "../../Types"

local SpecialKey = require "./SpecialKey"

local xtypeof = require "../../Utility/xtypeof"

-- local bindValueToAttribute = require "../bindValueToAttribute"

local function bindValueToAttribute(
	scope: Types.Scope,
	value: Types.Value<any>,
	instance: Instance,
	attribute: string
)
	if xtypeof(value) ~= "Value" then
		External.logError("expectedType", nil, "Value", typeof(value))
	end

	local event = instance:GetAttributeChangedSignal(attribute)

	value:set(instance:GetAttribute(attribute))

	table.insert(
		scope,
		event:Connect(function()
			value:set(instance:GetAttribute(attribute))
		end)
	)
end

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
