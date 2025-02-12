local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TextService = game:GetService('TextService')

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Element = Rusion.createElement
local Value = Rusion.createValue
local Computed = Rusion.createComputed

local Foreground = Color3.fromRGB(245, 247, 234)
local ActiveForeground = Color3.fromRGB(225, 86, 63)
local Background = Color3.fromRGB(45, 48, 50)

local HoverInfo = TweenInfo.new(0.4, Enum.EasingStyle.Circular)
local TooltipInfo = TweenInfo.new(0.2, Enum.EasingStyle.Exponential)

local function HotbarSlot(props)
	local tool = props.Item :: Tool
	local index = props.Index
	local callback = props.Callback

	local toolName = Value(tool.Name)
	toolName:bindToInstanceProperty(tool, 'Name')

	local toolTip = Value(tool.ToolTip)
	toolTip:bindToInstanceProperty(tool, 'ToolTip')

	local toolParent = Value(tool.Parent)
	toolParent:bindToInstanceProperty(tool, 'Parent')

	local isHovering = Value(false)
	local toolTipWidth = Computed(function(use)
		if not use(isHovering) then
			return 0
		end

		local bounds = TextService:GetTextSize(use(toolTip), 14, Enum.Font.SourceSans, Vector2.new(math.huge, 16))

		return bounds.X + 4
	end)

	local slotSize = Value(1)

	local currentBackpack = Players.LocalPlayer.Backpack

	return Element('TextButton', {
		Size = slotSize:map(function(size)
			return UDim2.fromScale(size, size)
		end),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,

		LayoutOrder = index,

		BackgroundColor3 = Background,
		BackgroundTransparency = 0.4,

		Text = toolName,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = Foreground,

		[Rusion.Event.Activated] = function(_, input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if callback then
					callback(index)
				end
			end
		end,
		[Rusion.Event.MouseEnter] = function()
			slotSize:tween(1.1, HoverInfo)
			isHovering:set(true)
		end,
		[Rusion.Event.MouseLeave] = function()
			slotSize:tween(1, HoverInfo)
			isHovering:set(false)
		end,
	}, {
		Stroke = Element('UIStroke', {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1,
			Color = toolParent:map(function(parent)
				if parent == currentBackpack then
					return Foreground
				end

				return ActiveForeground
			end),
		}),
		Round = Element('UICorner', {
			CornerRadius = UDim.new(0, 2),
		}),

		ToolTip = Element('TextLabel', {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0, -5),
			Size = Rusion.createTween(
				toolTipWidth:map(function(width)
					return UDim2.fromOffset(width, 16)
				end),
				TooltipInfo
			),

			Text = toolTip,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextColor3 = Foreground,

			ClipsDescendants = true,

			BackgroundTransparency = 0.5,
			BackgroundColor3 = Background,
		}),
		IndexLabel = Element('TextLabel', {
			Size = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,

			Text = tostring(index % 10),
			TextColor3 = Foreground,
		}),
	})
end

local HotbarComponent = Rusion.createComponent('Hotbar')

function HotbarComponent:init(props)
	local items = props.Items
	local updateSignal = props.UpdateSignal

	updateSignal:connect(function()
		self:setState({
			Items = items,
		})
	end)

	self:setState({
		Items = items,
	})
end

function HotbarComponent:render()
	local state = self.state
	local props = self.props
	local items = state.Items

	local slots = {}

	for index, tool: Tool in items do
		slots[index] = Element(HotbarSlot, { Item = tool, Index = index, Callback = props.EquipCallback })
	end

	local height = props.Height
	local padding = props.Padding

	local count = #slots

	return Element('Frame', {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -5),
		Size = UDim2.fromOffset(count * height + (count - 1) * padding, height),

		BackgroundTransparency = 1,
	}, {
		List = Rusion.createElement('UIListLayout', {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, padding),
		}),
		Slots = Rusion.createFragment(slots),
	})
end

return HotbarComponent
