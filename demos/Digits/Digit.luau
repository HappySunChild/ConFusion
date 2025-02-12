local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Computed = Rusion.createComputed
local Element = Rusion.createElement

local info = TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

local function DigitDisplay(props)
	local index = props.index
	local number = props.number

	local offset = Computed(function(use)
		return math.floor(use(number) / 10 ^ (index - 1)) % 10
	end)

	local labels = {}

	for i = 0, 9 do
		local position = offset:map(function(v)
			return UDim2.fromScale(0, i - v)
		end)

		labels[i] = Element('TextLabel', {
			Size = UDim2.fromScale(1, 1),
			Position = Rusion.createTween(position, info),

			BackgroundTransparency = 1,
			Text = i,
		})
	end

	return Element('Frame', {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, (index - 1) * -8, 0, 0),
		Size = UDim2.fromOffset(8, 20),

		ClipsDescendants = true,
		BackgroundTransparency = 1,
	}, labels)
end

return DigitDisplay
