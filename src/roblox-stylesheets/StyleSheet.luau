local memory = require "../memory/types"
local style = require "./types"

local Derives = require "./keys/Derives"
local Rules = require "./keys/Rules"

local Attribute = require "../roblox-instances/keys/Attribute"

local applyProperties = require "../roblox-instances/applyProperties"

local function StyleSheet(
	scope: memory.Scope,
	properties: style.StyleSheetProperties
): StyleSheet
	local newSheet = Instance.new "StyleSheet"

	table.insert(scope, newSheet)

	local actualProperties = {
		Parent = properties.parent,

		[Derives] = properties.derives,
		[Rules] = properties.rules,
	}

	local tokens = properties.tokens

	if tokens then
		for name, value in tokens do
			actualProperties[Attribute(name)] = value
		end
	end

	applyProperties(scope, newSheet, actualProperties)

	return newSheet
end

return StyleSheet
