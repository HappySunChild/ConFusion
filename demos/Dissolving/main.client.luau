local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)

local scope = Fusion:scoped()
local value = scope:Value(Color3.new(1, 1, 1))
local computed = scope:Computed(function(use: Fusion.Use, scope: Fusion.Scope)
	local children = {
		scope:New "Frame" {},
	}

	return scope:New "Frame" {
		Parent = workspace,
		BackgroundColor3 = use(value),

		[Fusion.Children] = children,
	}
end)

print(Fusion.peek(computed))
