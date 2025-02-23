local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local scope = Fusion:scoped()

local target = scope:Value(0)

local animatedSpring = scope:Animated(target, Fusion.Movers.Spring(10, 0.5))
local spring = scope:Spring(target, 10, 0.5)

scope:New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = {
		AnimatedFrame = scope:New "TextLabel" {
			Text = scope:Computed(function(use)
				return `AnimatedSpring: {use(animatedSpring)}`
			end),
			Size = scope:Computed(function(use)
				return UDim2.fromOffset(100 + use(animatedSpring) * 100, 100)
			end),
		},

		SpringFrame = scope:New "TextLabel" {
			Text = scope:Computed(function(use)
				return `RegularSpring: {use(spring)}`
			end),
			Position = UDim2.fromOffset(0, 110),
			Size = scope:Computed(function(use)
				return UDim2.fromOffset(100 + use(spring) * 100, 100)
			end),
		},
	},
}

while true do
	target:set(mouse.X / mouse.ViewSizeX * 5)
	task.wait()
end
