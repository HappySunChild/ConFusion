local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local doCleanup = require(package.Memory.doCleanup)

local Cleanup: Types.SpecialKey = {
	[Symbols.Kind] = Kinds.Key,
	[Symbols.Type] = Types.Cleanup,

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
