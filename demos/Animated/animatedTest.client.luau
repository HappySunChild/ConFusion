local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local map = Fusion.map
local scope = Fusion:scoped()

local target = scope:Value(0)

local children = {}

local function debugValueDisplay(target)
	table.insert(
		children,
		scope:New "Frame" {
			Position = UDim2.fromOffset(0, #children * 16),
			Size = map(target, function(value)
				return UDim2.fromOffset(value, 15)
			end),
		}
	)
end

local singleSpring = scope:Spring(target, 20, 1)
local doubleSpring = scope:Tween(singleSpring, TweenInfo.new(0.1))

debugValueDisplay(target)
debugValueDisplay(singleSpring)
debugValueDisplay(doubleSpring)

scope:New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = children,
}

local mouse = Players.LocalPlayer:GetMouse()

while true do
	target:set(mouse.X)
	task.wait()
end
