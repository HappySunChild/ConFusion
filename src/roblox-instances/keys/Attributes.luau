local calc = require("../../core-calc/types")
local memory = require("../../core-memory/types")

local peek = require("../../core-use/peek")

local observe_immediate = require("../../core-graph/observe_immediate")

local SpecialKey = require("./SpecialKey")

local Attributes = SpecialKey(
	"self",
	"Attributes",
	function(
		scope: memory.Scope,
		apply_to: Instance,
		attributes: { [string]: calc.UsedAs<any> }
	)
		for attr, attr_value in attributes do
			observe_immediate(scope, attr_value, function()
				apply_to:SetAttribute(attr, peek(attr_value))
			end)
		end
	end
)

return Attributes
