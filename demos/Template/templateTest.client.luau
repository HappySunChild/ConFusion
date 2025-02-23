local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children, scoped = Fusion.Children, Fusion.scoped

local template = ReplicatedStorage:WaitForChild "Template"

local scope = scoped(Fusion)

scope:New(template) {
	Parent = Players.LocalPlayer.PlayerGui,

	[Children] = {
		scope:DescendantOfClass "TextLabel" {
			Text = "Test",
			BackgroundColor3 = Color3.new(1, 0, 0),
		},
	},
}
