local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local map = Fusion.map
local scope = Fusion:scoped()

local target = scope:Value(0)

local children = {}

local function debugValueDisplay(target, compareTarget)
	table.insert(
		children,
		scope:New "Frame" {
			Position = UDim2.fromOffset(0, #children * 16),
			Size = map(target, function(value)
				return UDim2.fromOffset(value, 15)
			end),

			[Fusion.Children] = compareTarget and {
				Diff = scope:New "Frame" {
					BackgroundColor3 = Color3.new(1, 0, 0),
					BackgroundTransparency = 0.5,

					Position = UDim2.fromScale(1, 0),
					AnchorPoint = Vector2.new(1, 0),
					Size = scope:Computed(function(use)
						return UDim2.new(0, use(target) - use(compareTarget), 1, 0)
					end),
				},
			},
		}
	)
end

local singleSpring = scope:Spring(target, 10, 0.5)
local doubleSpring = scope:Spring(singleSpring, 10, 0.5)

debugValueDisplay(target)
debugValueDisplay(singleSpring, target)
debugValueDisplay(doubleSpring, target)

scope:New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = children,
}

local mouse = Players.LocalPlayer:GetMouse()

while true do
	target:set(mouse.X)
	task.wait()
end
