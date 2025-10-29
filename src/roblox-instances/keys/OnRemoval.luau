local memory = require "../../core-memory/types"

local SpecialKey = require "./SpecialKey"
local doCleanup = require "../../core-memory/doCleanup"

return SpecialKey "observer" {
	name = "OnRemoval",
	apply = function(
		scope: memory.Scope,
		apply_to: Instance,
		removalTask: memory.CleanupTask
	)
		table.insert(
			scope,
			apply_to.AncestryChanged:Connect(function(_, parent: Instance?)
				if parent == nil then
					doCleanup(removalTask)
				end
			end)
		)
	end,
}
