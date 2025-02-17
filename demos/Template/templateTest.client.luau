local Players = game:GetService 'Players'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local scoped, WithChild = Fusion.scoped, Fusion.WithChild

local template = ReplicatedStorage:WaitForChild 'Template'

local scope = scoped(Fusion)

scope:New(template) {
	Parent = Players.LocalPlayer.PlayerGui,

	[WithChild 'Frame'] = {
		BackgroundColor3 = Fusion.Clock:map(function(t)
			return Color3.fromHSV(t % 1, 1, 1)
		end),
	},
}
