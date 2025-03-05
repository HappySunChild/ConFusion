local ContextActionService = game:GetService "ContextActionService"
local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"
local StarterGui = game:GetService "StarterGui"
local Teams = game:GetService "Teams"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local peek, observe = Fusion.peek, Fusion.observe
local PlayerList = require(script.Parent.List)

local scoped = Fusion:scoped { PlayerList = PlayerList }

local isVisible = scoped:Value(true)
local players = scoped:Value(Players:GetPlayers())
local teams = scoped:Value(Teams:GetChildren())

local function updateTeams()
	teams:set(Teams:GetChildren())
end

local function updatePlayers()
	players:set(Players:GetPlayers())
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

ContextActionService:BindAction("Debug", function(_, state)
	if state == Enum.UserInputState.Begin then
		updatePlayers()
		updateTeams()
	end
end, false, Enum.KeyCode.B)

print(teams)

observe(teams, function()
	print "teams changed"
end)

scoped:New "ScreenGui" {
	Name = "PlayerList",
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = {
		scoped:PlayerList {
			IsVisible = isVisible,
			Players = players,
			Teams = teams,
		},
	},
}
