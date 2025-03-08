local ContextActionService = game:GetService "ContextActionService"
local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"
local StarterGui = game:GetService "StarterGui"
local Teams = game:GetService "Teams"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local peek = Fusion.peek
local PlayerList = require(script.Parent.List)

local scoped = Fusion:scoped { PlayerList = PlayerList }

local isVisible = scoped:Value(true)
local playerList = scoped:Value(Players:GetPlayers())
local teamList = scoped:Value(Teams:GetChildren())

local function fakePlayer(name: string, displayName: string?)
	return {
		Name = name,
		DisplayName = displayName or name,
		UserId = Players:GetUserIdFromNameAsync(name),
		HasVerifiedBadge = true,
		Team = Teams:GetChildren()[math.random(#Teams:GetChildren())],
	}
end

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

ContextActionService:BindAction("Debug", function(_, state)
	if state == Enum.UserInputState.Begin then
		updatePlayers()
		updateTeams()
	end
end, false, Enum.KeyCode.B)

scoped:New "ScreenGui" {
	Name = "PlayerList",
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = {
		scoped:PlayerList {
			IsVisible = isVisible,
			Players = playerList,
			Teams = teamList,
		},
	},
}

task.wait(1)

local createdPlayers = {}
local possiblePlayers = {
	fakePlayer "RL1te",
	fakePlayer "Roblox",
	fakePlayer "builderman",
	fakePlayer "david.baszucki",
	fakePlayer "EC_DN",
	fakePlayer("HelloMan4500", "Tenthusiast"),
	fakePlayer "Defaultio",
	fakePlayer "EBOctoLuck",
}

for _, player in possiblePlayers do
	table.insert(createdPlayers, player)

	playerList:set { Players.LocalPlayer, unpack(createdPlayers) }

	task.wait(0.1)
end
