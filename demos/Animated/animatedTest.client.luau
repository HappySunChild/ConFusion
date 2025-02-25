local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local scope = Fusion:scoped()

local target = scope:Value(0)

local children = {}

for i = 0, 20 do
	local animated = scope:Delay(target, i / 20)

	table.insert(
		children,
		scope:New "TextLabel" {
			Text = `Delay {i}`,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(0, i * 16),
			Size = scope:Computed(function(use)
				return UDim2.fromOffset(use(animated), 15)
			end),
			BackgroundColor3 = Color3.fromHSV(0, 0, 1 - (i / 20)),
		}
	)
end

scope:New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = children,
}

while true do
	target:set(mouse.X)
	task.wait()
end
