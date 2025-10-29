local calc = require "../../core-calc/types"
local instances = require "../types"
local memory = require "../../core-memory/types"

local SpecialKey = require "./SpecialKey"
local observe = require "../../core-graph/observe"
local peek = require "../../core-use/peek"

local KEY_CACHE = {}

local function Attribute(attribute: string): instances.SpecialKey<"Attribute">
	local key = KEY_CACHE[attribute]

	if key == nil then
		key = SpecialKey "self" {
			name = `Attribute_{attribute}`,
			apply = function(
				scope: memory.Scope,
				apply_to: Instance,
				value: calc.UsedAs<any>
			)
				observe(scope, value, function()
					apply_to:SetAttribute(attribute, peek(value))
				end, true)
			end,
		}

		KEY_CACHE[attribute] = key
	end

	return key
end

return Attribute
