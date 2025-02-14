local Players = game:GetService 'Players'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local TextService = game:GetService 'TextService'

local Rusion = require(ReplicatedStorage.Libraries.ReFusion)
local OnEvent = Rusion.OnEvent

local Foreground = Color3.fromRGB(245, 247, 234)
local ActiveForeground = Color3.fromRGB(225, 86, 63)
local Background = Color3.fromRGB(45, 48, 50)

local HoverInfo = TweenInfo.new(0.4, Enum.EasingStyle.Circular)
local TooltipInfo = TweenInfo.new(0.2, Enum.EasingStyle.Exponential)

local function HotbarSlot(
	scope: Rusion.Scope,
	props: { Item: Tool, Index: number, Callback: () -> (), Cleanup: () -> () }
)
	local slotScope = scope:innerScope()

	local tool = props.Item :: Tool
	local index = props.Index
	local callback = props.Callback

	local toolName = slotScope:Value(tool.Name)
	local toolParent = slotScope:Value(tool.Parent)
	local toolTip = slotScope:Value(tool.ToolTip)
	local toolIcon = slotScope:Value(tool.TextureId)

	toolName:bindToInstanceProperty(tool, 'Name')
	toolParent:bindToInstanceProperty(tool, 'Parent')
	toolTip:bindToInstanceProperty(tool, 'ToolTip')
	toolIcon:bindToInstanceProperty(tool, 'TextureId')

	local isHovering = slotScope:Value(false)
	local toolTipWidth = slotScope:Computed(function(use)
		if not use(isHovering) then
			return 0
		end

		local bounds = TextService:GetTextSize(use(toolTip), 14, Enum.Font.SourceSans, Vector2.new(math.huge, 16))

		return bounds.X + 4
	end)

	local slotSize = slotScope:Value(0.5)

	local currentBackpack = Players.LocalPlayer.Backpack

	return slotScope:New('TextButton', {
		Size = slotScope:Tween(
			slotSize:map(function(size)
				return UDim2.fromScale(size, size)
			end),
			HoverInfo
		),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,

		LayoutOrder = index,

		BackgroundColor3 = Background,
		BackgroundTransparency = 0.4,

		Text = slotScope:Computed(function(use)
			if use(toolIcon) ~= '' then
				return ''
			end

			local text = use(toolName)

			return text
		end),
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = Foreground,

		[Rusion.Cleanup] = {
			slotScope,
			props.Cleanup,
		},
		[Rusion.Startup] = function()
			slotSize:set(1)
		end,

		[OnEvent 'InputBegan'] = function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if callback then
					callback(index)
				end
			end
		end,
		[OnEvent 'MouseEnter'] = function()
			slotSize:set(1.1)
			isHovering:set(true)
		end,
		[OnEvent 'MouseLeave'] = function()
			slotSize:set(1)
			isHovering:set(false)
		end,
	}, {
		Stroke = slotScope:New('UIStroke', {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1,
			Color = toolParent:map(function(parent)
				if parent == currentBackpack then
					return Foreground
				end

				return ActiveForeground
			end),
		}),
		Round = slotScope:New('UICorner', {
			CornerRadius = UDim.new(0, 2),
		}),

		IconImage = toolIcon:map(function(value)
			if value ~= '' then
				return slotScope:New('ImageLabel', {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.8, 0.8),

					BackgroundTransparency = 1,
					Image = toolIcon,
				})
			end

			return
		end),
		ToolTip = slotScope:New('TextLabel', {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0, -5),
			Size = slotScope:Tween(
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
		IndexLabel = slotScope:New('TextLabel', {
			Size = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,

			Text = tostring(index % 10),
			TextColor3 = Foreground,
			ZIndex = 10,
		}),
	})
end

return HotbarSlot
