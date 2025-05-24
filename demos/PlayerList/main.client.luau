local ContextActionService = game:GetService "ContextActionService"
local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"
local StarterGui = game:GetService "StarterGui"
local Teams = game:GetService "Teams"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local peek = Fusion.peek
local PlayerList = require(script.Parent.List)

local scope = Fusion:scoped { PlayerList = PlayerList }

local isVisible = scope:Value(true)
local playerList = scope:Value(Players:GetPlayers())
local teamList = scope:Value(Teams:GetChildren())

local function updateTeams()
	teamList:set(Teams:GetChildren())
end

local function updatePlayers()
	playerList:set(Players:GetPlayers())
end

Teams.ChildAdded:Connect(updateTeams)
Teams.ChildRemoved:Connect(updateTeams)

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

ContextActionService:BindAction("TogglePlayerList", function(_, state)
	if state == Enum.UserInputState.Begin then
		isVisible:set(not peek(isVisible) :: boolean)
	end
end, false, Enum.KeyCode.Tab)

scope:New "ScreenGui" {
	Name = "PlayerList",
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = {
		scope:PlayerList {
			IsVisible = isVisible,
			Players = playerList,
			Teams = teamList,
		},
	},
}
