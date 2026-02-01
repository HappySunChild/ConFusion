local calc = require("../../core-calc/types")
local memory = require("../../core-memory/types")

local SpecialKey = require("../SpecialKey")
local observe_immediate = require("../../core-graph/observe_immediate")
local peek = require("../../core-use/peek")

local function apply_attribute(
	scope: memory.Scope,
	apply_to: Instance,
	attribute: string,
	value: calc.UsedAs<any>
)
	observe_immediate(scope, value, function()
		apply_to:SetAttribute(attribute, peek(value))
	end)
end

local Attributes = SpecialKey(
	"self",
	"Attributes",
	function(scope: memory.Scope, apply_to: Instance, attributes: { [string]: calc.UsedAs<any> })
		for attribute, value in attributes do
			apply_attribute(scope, apply_to, attribute, value)
		end
	end
)

return Attributes
