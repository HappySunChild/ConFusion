local memory = require "../../core-memory/types"

local SpecialKey = require "./SpecialKey"
local destroy = require "../../core-memory/destroy"

return SpecialKey(
	"observer",
	"OnRemoval",
	function(scope: memory.Scope, apply_to: Instance, removal_task: memory.CleanupTask)
		table.insert(
			scope,
			apply_to.AncestryChanged:Connect(function(_, parent: Instance?)
				if parent == nil then
					destroy(removal_task)
				end
			end)
		)
	end
)
