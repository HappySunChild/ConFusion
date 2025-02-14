local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local doCleanup = require(package.Memory.doCleanup)

local Cleanup: Types.SpecialKey = table.freeze {
	[Symbols.Kind] = 'key',
	[Symbols.Type] = 'cleanup',

	apply = function(scope: Types.Scope, instance: Instance, task: Types.Task)
		table.insert(
			scope,
			instance.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					doCleanup(task)
				end
			end)
		)
	end,
}

return Cleanup
