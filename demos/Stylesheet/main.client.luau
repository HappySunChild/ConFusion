local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)

local scope = Fusion:scoped()

local timer = scope:Timer()
local idleColor = scope:Computed(function(use: Fusion.Use)
	local now = use(timer)

	return Color3.fromHSV(now % 1, 1, 1)
end)

local hoverColor = scope:Computed(function(use: Fusion.Use)
	local idleColor = use(idleColor)

	return idleColor:Lerp(Color3.new(0, 0, 0), 0.2)
end)

local StyleSheet = scope:StyleSheet {
	Parent = ReplicatedStorage,
	Name = "TestStyle",

	Tokens = {
		HoverColor = hoverColor,
		IdleColor = idleColor,
	},
	Rules = {
		scope:StyleRule "Frame" {
			BackgroundColor3 = "$IdleColor",

			Rules = {
				scope:StyleRule ":Hover" {
					BackgroundColor3 = "$HoverColor",
				},
			},
		},
	},
}

local children = table.create(20 ^ 2)

for x = 1, 20 do
	for y = 1, 20 do
		children[x + y * 20] = scope:New "Frame" {
			Name = "Frame" .. x .. y,
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.fromOffset((x - 1) * 22, (y - 1) * 22),

			[Fusion.Default] = { "BackgroundColor3" },
		}
	end
end

scope:New "ScreenGui" {
	Parent = Players.LocalPlayer.PlayerGui,
	Name = "StylesheetTest",

	[Fusion.StyleLink] = StyleSheet,
	[Fusion.Children] = children,
}
