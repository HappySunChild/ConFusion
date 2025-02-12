local ContextActionService = game:GetService('ContextActionService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Element = Rusion.createElement
local Value = Rusion.createValue

local Display = require(script.Parent.Display)

local number = Value(123)
number:bindToInstanceProperty(workspace.Number, 'Value')

Rusion.mount(
	Element('ScreenGui', nil, {
		Element(Display, {
			digits = 8,
			number = number,
		}),
	}),
	Players.LocalPlayer.PlayerGui,
	'DigitDisplayDemo'
)

ContextActionService:BindAction('Increment', function(_, state)
	if state == Enum.UserInputState.Begin then
		workspace.Number.Value += 1
	end
end, false, Enum.KeyCode.E)

ContextActionService:BindAction('Decrement', function(_, state)
	if state == Enum.UserInputState.Begin then
		workspace.Number.Value -= 1
	end
end, false, Enum.KeyCode.Q)
