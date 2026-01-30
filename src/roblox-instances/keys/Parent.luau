local calc = require("../../core-calc/types")
local instances = require("../types")
local memory = require("../../core-memory/types")

local External = require("../../core-external/External")

local peek = require("../../core-use/peek")

local observe_immediate = require("../../core-graph/observe_immediate")

local SpecialKey = require("./SpecialKey")

local function set_parent(instance: Instance, parent: Instance?)
	local success, err = pcall(function()
		instance.Parent = parent
	end)

	if not success then
		External.log_warn(err)
	end
end

return SpecialKey(
	"ancestor",
	"Parent",
	function(scope: memory.Scope, apply_to: Instance, parent: calc.UsedAs<Instance?>)
		observe_immediate(scope, parent, function()
			set_parent(apply_to, peek(parent))
		end)
	end
) :: instances.SpecialKey<"Parent">
