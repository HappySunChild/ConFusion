local ContextActionService = game:GetService('ContextActionService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

local player = Players.LocalPlayer

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local HotbarComponent = require(script.Parent.HotbarComponent)

local Rusion = require(ReplicatedStorage.Libraries.ReactFusion)
local Element = Rusion.createElement

local keys = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero,
}

local items = {}
local currentTool = nil

local updateSignal = Rusion.createSignal()

-- utility functions

local function find(tab, value)
	for k, v in tab do
		if v == value then
			return k
		end
	end
end

local function getLowestAvailableIndex(tab)
	local index = 1

	while tab[index] do
		index += 1
	end

	return index
end

-- backpack functions

local function equipTool(index: number)
	local selectedTool = items[index]

	if not selectedTool then
		return
	end

	if currentTool and currentTool:IsDescendantOf(workspace) then
		local curTool = currentTool -- this is gross but it works

		currentTool.Parent = player.Backpack

		if selectedTool == curTool then
			return
		end
	end

	selectedTool.Parent = player.Character
end

local function removeTool(tool: Tool)
	local index = find(items, tool)

	if index then
		items[index] = nil

		updateSignal:fire()
	end
end

local function addTool(child: Instance)
	if not child:IsA('Tool') then
		return
	end

	if find(items, child) then
		return
	end

	local connection
	connection = child.AncestryChanged:Connect(function(_, parent)
		if parent == nil or parent ~= player.Backpack and parent ~= player.Character then
			connection:Disconnect()

			removeTool(child)
		end
	end)

	items[getLowestAvailableIndex(items)] = child

	updateSignal:fire()
end

-- event functions

local function characterAdded(character: Model)
	local backpack = player:WaitForChild('Backpack')

	backpack.ChildAdded:Connect(addTool)

	for _, child in backpack:GetChildren() do
		addTool(child)
	end

	character.ChildAdded:Connect(function(child)
		addTool(child)

		if child:IsA('Tool') then
			currentTool = child
		end
	end)
	character.ChildRemoved:Connect(function(child)
		if child == currentTool then
			currentTool = nil
		end
	end)
end

Rusion.mount(
	Element('ScreenGui', nil, {
		Hotbar = Element(HotbarComponent, {
			UpdateSignal = updateSignal,

			Height = 50,
			Padding = 5,

			Items = items,
			EquipCallback = equipTool,
		}),
	}),
	player.PlayerGui,
	'InventoryHotbar'
)

ContextActionService:BindAction('Equip', function(_, state: Enum.UserInputState, input: InputObject)
	if state ~= Enum.UserInputState.Begin then
		return
	end

	local index = table.find(keys, input.KeyCode)

	equipTool(index)
end, false, unpack(keys))

characterAdded(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(characterAdded)
