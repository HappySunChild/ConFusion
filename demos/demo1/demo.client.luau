local Players = game:GetService 'Players'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Rusion = require(ReplicatedStorage.Libraries.ReFusion)
local New = Rusion.New
local Value = Rusion.Value
local Children = Rusion.Children
local OnEvent = Rusion.OnEvent

local background = Value(Color3.new(1, 0, 0))

local frame = New('Frame', {
	Size = UDim2.fromOffset(100, 100),
	BackgroundColor3 = background,

	[OnEvent 'MouseEnter'] = function()
		background:set(Color3.new(1, 1, 1))
	end,
	[OnEvent 'MouseLeave'] = function()
		background:set(Color3.new(1, 0, 0))
	end,

	[Children] = {
		New('Frame', {
			Size = UDim2.fromScale(0.5, 1),
			BackgroundColor3 = Color3.new(0, 1, 0),
		}),
	},
})

New('ScreenGui', {
	Parent = Players.LocalPlayer.PlayerGui,

	[Children] = {
		frame,
	},
})
