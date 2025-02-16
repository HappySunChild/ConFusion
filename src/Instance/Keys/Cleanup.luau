local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local doCleanup = require(package.Memory.doCleanup)

local Cleanup: Types.SpecialKey = table.freeze {
	kind = 'key',
	type = 'cleanup',

	apply = function(scope: Types.Scope, applyTo: Instance, task: Types.Task)
		table.insert(
			scope,
			applyTo.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					doCleanup(task)
				end
			end)
		)
	end,
}

return Cleanup
