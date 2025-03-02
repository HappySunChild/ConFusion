local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local map = Fusion.map
local scope = Fusion:scoped()

local target = scope:Value(Vector2.zero)

local children = {}

local function debugValueDisplay(target)
	table.insert(
		children,
		scope:New "Frame" {
			Position = map(target, function(v)
				return UDim2.fromOffset(v.X, v.Y)
			end),
			Size = UDim2.fromOffset(20, 20),
		}
	)
end

local singleSpring = scope:Spring(target, 20, 0.5)
local doubleSpring = scope:Spring(singleSpring, 20, 0.5)
local tripleSpring = scope:Spring(doubleSpring, 10, 0.2)

debugValueDisplay(target)
debugValueDisplay(singleSpring)
debugValueDisplay(doubleSpring)
debugValueDisplay(tripleSpring)

scope:New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = children,
}

local mouse = Players.LocalPlayer:GetMouse()

while true do
	target:set(Vector2.new(mouse.X, mouse.Y))

	task.wait()
end
