local calc = require "../../core-calc/types"
local instances = require "../types"
local memory = require "../../core-memory/types"

local SpecialKey = require "./SpecialKey"
local observeImmediate = require "../../core-graph/observeImmediate"
local peek = require "../../core-use/peek"

local KEY_CACHE = {}

local function Attribute(attribute: string): instances.SpecialKey<"Attribute">
	local key = KEY_CACHE[attribute]

	if key == nil then
		key = SpecialKey(
			"self",
			"Attribute",
			function(scope: memory.Scope, apply_to: Instance, value: calc.UsedAs<any>)
				observeImmediate(scope, value, function()
					apply_to:SetAttribute(attribute, peek(value))
				end)
			end
		)

		KEY_CACHE[attribute] = key
	end

	return key
end

return Attribute
