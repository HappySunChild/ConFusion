local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)

local StyleSheet = ReplicatedStorage.Design.StyleSheet

local scope = Fusion:scoped()
local valueSheet = scope:Value(StyleSheet)

scope:New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,
	Name = "StylesheetTest",

	[Fusion.StyleSheet] = valueSheet,
	[Fusion.Children] = {
		scope:New "Frame" {
			Size = UDim2.fromOffset(100, 100),
		},
	},
}

task.wait(5)

valueSheet:set(nil)
