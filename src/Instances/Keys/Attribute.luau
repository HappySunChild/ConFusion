local Types = require "../../Types"

local observe = require "../../Graph/observe"

local castToState = require "../../State/castToState"
local peek = require "../../State/peek"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function Attribute(attribute: string): Types.SpecialKey<"Attribute">
	local key = keyCache[attribute]

	if not key then
		key = SpecialKey "Attribute" {
			stage = "self",
			apply = function(
				scope: Types.Scope,
				applyTo: Instance,
				value: Types.UsedAs<any>
			)
				if castToState(value) then
					observe(scope, value, function()
						applyTo:SetAttribute(attribute, peek(value))
					end)
				end

				applyTo:SetAttribute(attribute, peek(value))
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return Attribute
