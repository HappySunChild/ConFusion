local calc = require "../../calc/types"
local instances = require "../types"
local memory = require "../../memory/types"

local xtypeof = require "../../xtypeof"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function AttributeOut(attribute: string): instances.SpecialKey<"AttributeOut">
	local key = keyCache[attribute]

	if not key then
		key = SpecialKey "AttributeOut" {
			stage = "observer",
			apply = function(
				scope: memory.Scope,
				applyTo: Instance,
				value: calc.Value<any>
			)
				if xtypeof(value) ~= "Value" then
					return error(`Invalid Out type.`, 2)
				end

				local event = applyTo:GetAttributeChangedSignal(attribute)

				table.insert(
					scope,
					event:Connect(function()
						value:set(applyTo:GetAttribute(attribute))
					end)
				)

				return
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return AttributeOut
