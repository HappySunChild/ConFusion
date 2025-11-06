local memory = require "../../core-memory/types"

local SpecialKey = require "./SpecialKey"
local doCleanup = require "../../core-memory/doCleanup"

return SpecialKey(
	"observer",
	"OnRemoval",
	function(scope: memory.Scope, apply_to: Instance, removal_task: memory.CleanupTask)
		table.insert(
			scope,
			apply_to.AncestryChanged:Connect(function(_, parent: Instance?)
				if parent == nil then
					doCleanup(removal_task)
				end
			end)
		)
	end
)
