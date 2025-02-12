local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Element = Rusion.createElement

local Digit = require(script.Parent.Digit)

local function Display(props)
	local digitDisplay = {}
	local digits = props.digits

	for i = 1, digits do
		digitDisplay[i] = Element(Digit, { index = i, number = props.number })
	end

	return Element('Frame', {
		Size = UDim2.fromOffset(digits * 8, 20),
	}, digitDisplay)
end

return Display
