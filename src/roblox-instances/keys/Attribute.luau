local calc = require("../../core-calc/types")
local instances = require("../types")
local memory = require("../../core-memory/types")

local peek = require("../../core-use/peek")

local observe_immediate = require("../../core-graph/observe_immediate")

local SpecialKey = require("./SpecialKey")

local KEY_CACHE = {}

local function Attribute(attribute: string): instances.SpecialKey<"Attribute">
	local key = KEY_CACHE[attribute]

	if key == nil then
		key = SpecialKey(
			"self",
			"Attribute",
			function(scope: memory.Scope, apply_to: Instance, value: calc.UsedAs<any>)
				observe_immediate(scope, value, function()
					apply_to:SetAttribute(attribute, peek(value))
				end)
			end
		)

		KEY_CACHE[attribute] = key
	end

	return key
end

return Attribute
