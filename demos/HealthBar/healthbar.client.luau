local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local player = Players.LocalPlayer

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Element = Rusion.createElement
local Value = Rusion.createValue
local Computed = Rusion.createComputed

local maxHealth = Value(100)
local health = Value(100)

local text = Computed(function(use)
	return `{use(health)}/{use(maxHealth)}`
end)

Rusion.mount(
	Element('ScreenGui', nil, {
		Container = Element('CanvasGroup', {
			AnchorPoint = Vector2.new(1, 1),
			Size = UDim2.fromOffset(200, 20),
			Position = UDim2.new(1, -10, 1, -10),

			BackgroundTransparency = 0.3,
			BackgroundColor3 = Color3.fromRGB(41, 47, 68),
		}, {
			Label = Element('TextLabel', {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,

				Text = text,
				TextSize = 16,
				TextColor3 = Color3.new(1, 1, 1),
			}),
			Bar = Element('Frame', {
				Size = Rusion.createTween(
					Computed(function(use)
						return UDim2.fromScale(use(health) / use(maxHealth), 1)
					end),
					TweenInfo.new(0.3, Enum.EasingStyle.Exponential)
				),
				BackgroundTransparency = 0.2,
				BackgroundColor3 = Color3.fromRGB(226, 75, 75),
			}),

			Round = Element('UICorner', {
				CornerRadius = UDim.new(0, 2),
			}),
			Stroke = Element('UIStroke', {
				Color = Color3.new(1, 1, 1),
				Thickness = 1,
			}),
		}),
	}),
	player.PlayerGui,
	'HealthBar'
)

local function characterAdded(character: Model)
	local humanoid = character:WaitForChild('Humanoid') :: Humanoid

	health:set(humanoid.Health)
	maxHealth:set(humanoid.MaxHealth)

	humanoid.HealthChanged:Connect(function(newHealth)
		health:set(newHealth)
		maxHealth:set(humanoid.MaxHealth)
	end)
end

characterAdded(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(characterAdded)
