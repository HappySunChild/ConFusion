local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children, Startup, OnEvent = Fusion.Children, Fusion.Startup, Fusion.OnEvent

local VERIFIED_BADGE = utf8.char(0xE000)
local PREMIUM_BADGE = utf8.char(0xE001)

local HOVER_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Cubic)

local ICONS = {
	Developer = {
		Id = "rbxasset://LuaPackages/Packages/_Index/FoundationImages/FoundationImages/SpriteSheets/img_set_1x_8.png",
		ImageRectOffset = Vector2.new(132, 494),
	},
	Friends = {
		Id = "rbxasset://LuaPackages/Packages/_Index/FoundationImages/FoundationImages/SpriteSheets/img_set_1x_8.png",
		ImageRectOffset = Vector2.new(114, 494),
	},
}

local function getFormattedName(player: Player)
	local formattedName = player.DisplayName

	if player.HasVerifiedBadge then
		formattedName = formattedName .. VERIFIED_BADGE
	end

	if player.MembershipType == Enum.MembershipType.Premium then
		formattedName = PREMIUM_BADGE .. " " .. formattedName
	end

	return formattedName
end

local function determineIcon(player: Player)
	if player.UserId == game.CreatorId then
		return ICONS.Developer
	elseif Players.LocalPlayer:IsFriendsWith(player.UserId) then
		return ICONS.Friends
	end

	return nil
end

local function getLayoutOrder(team: Team, teams: { Team })
	local currentTeam = team

	if currentTeam then
		local index = table.find(teams, currentTeam)

		if index ~= nil then
			return (index - 1) * 2 + 1
		end
	end

	return #teams * 2 + 1
end

local function Player(
	scope: Fusion.Scope,
	props: { Player: Player, Teams: { Team }, IsLast: boolean }
)
	local player = props.Player
	local icon = determineIcon(player)

	local offset = scope:Value(UDim2.fromScale(1, 0))
	local hovering = scope:Value(false)

	local currentTeam = scope:Value(player.Team)
	currentTeam:bindToInstanceProperty(player, "Team")

	return scope:New "Frame" {
		Name = `p_{player.UserId}`,
		BackgroundTransparency = 1,

		LayoutOrder = scope:Computed(function(use)
			return getLayoutOrder(use(currentTeam), props.Teams)
		end),

		ClipsDescendants = true,

		Size = UDim2.new(1, 0, 0, 32),

		[OnEvent "MouseLeave"] = function()
			hovering:set(false)
		end,
		[OnEvent "MouseEnter"] = function()
			hovering:set(true)
		end,

		[Startup] = function()
			offset:set(UDim2.fromScale(0, 0))
		end,

		[Children] = {
			Content = scope:New "Frame" {
				Position = scope:Spring(offset, 16, 0.8),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),

				[Children] = {
					Padding = scope:New "UIPadding" {
						PaddingLeft = UDim.new(0, 6),
						PaddingRight = UDim.new(0, 10),
					},

					PlayerName = scope:New "Frame" {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(50, 0),
						Size = UDim2.new(1, -50, 1, 0),

						[Children] = {
							DisplayName = scope:New "TextLabel" {
								Text = getFormattedName(player),
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextTruncate = Enum.TextTruncate.AtEnd,
								TextColor3 = Color3.new(1, 1, 1),
								Font = Enum.Font.GothamMedium,

								BackgroundTransparency = 1,
								TextTransparency = scope:Tween(
									scope:Computed(function(use)
										return use(hovering) and 1 or 0
									end),
									HOVER_TWEENINFO
								),

								Size = UDim2.fromScale(1, 1),
							},

							Username = scope:New "TextLabel" {
								Text = `@{player.Name}`,
								TextSize = 14,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextTruncate = Enum.TextTruncate.AtEnd,
								TextColor3 = Color3.new(0.6, 0.6, 0.6),
								Font = Enum.Font.GothamMedium,

								BackgroundTransparency = 1,
								TextTransparency = scope:Tween(
									scope:Computed(function(use)
										return use(hovering) and 0 or 1
									end),
									HOVER_TWEENINFO
								),

								Size = UDim2.fromScale(1, 1),
							},
						},
					},

					Icon = if icon ~= nil
						then scope:New "ImageLabel" {
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 0, 0.5, 0),
							Size = UDim2.fromOffset(16, 16),

							Image = icon.Id,
							ImageRectOffset = icon.ImageRectOffset,
							ImageRectSize = Vector2.new(16, 16),

							BackgroundTransparency = 1,
						}
						else nil,
					PlayerImage = scope:New "ImageLabel" {
						Image = scope:Eventual(function(_, become)
							become(
								Players:GetUserThumbnailAsync(
									player.UserId,
									Enum.ThumbnailType.HeadShot,
									Enum.ThumbnailSize.Size48x48
								)
							)
						end, "rbxthumb://type=AvatarHeadShot&id=1&w=48&h=48"),

						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 22, 0.5, 0),
						Size = UDim2.fromOffset(24, 24),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,

						BackgroundColor3 = Color3.fromRGB(103, 103, 103),
						BackgroundTransparency = 0.5,

						[Children] = {
							scope:New "UICorner" {
								CornerRadius = UDim.new(1, 0),
							},
						},
					},
				},
			},

			Divider = if props.IsLast == false
				then scope:New "Frame" {
					AnchorPoint = Vector2.new(0, 1),
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.new(1, 0, 0, 1),

					BackgroundColor3 = Color3.fromRGB(46, 46, 46),
					BackgroundTransparency = 0.4,
				}
				else nil,
		},
	}
end

return Player
