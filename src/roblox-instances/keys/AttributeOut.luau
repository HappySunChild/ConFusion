local calc = require "../../core-calc/types"
local instances = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"
local SpecialKey = require "./SpecialKey"
local xtypeof = require "../../xtypeof"

local KEY_CACHE = {}

local function AttributeOut(attribute: string): instances.SpecialKey<"AttributeOut">
	local key = KEY_CACHE[attribute]

	if key == nil then
		key = SpecialKey "observer" {
			name = `AttributeOut_{attribute}`,
			apply = function(
				scope: memory.Scope,
				apply_to: Instance,
				value: calc.Value<any>
			)
				if xtypeof(value) ~= "Value" then
					External.logError(
						instances.expected_type,
						nil,
						"Value",
						xtypeof(value)
					)
				end

				local event = apply_to:GetAttributeChangedSignal(attribute)

				table.insert(
					scope,
					event:Connect(function()
						value:set(apply_to:GetAttribute(attribute))
					end)
				)

				return
			end,
		}

		KEY_CACHE[attribute] = key
	end

	return key
end

return AttributeOut
