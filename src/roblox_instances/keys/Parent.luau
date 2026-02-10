local calc = require("../../core_calc/types")
local instances = require("../types")
local memory = require("../../core_memory/types")

local External = require("../../core_external/External")
local SpecialKey = require("../SpecialKey")
local observe_immediate = require("../../core_graph/observe_immediate")
local peek = require("../../core_use/peek")

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
