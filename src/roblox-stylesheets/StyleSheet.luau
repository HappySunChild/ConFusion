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
	local new_sheet = Instance.new "StyleSheet"

	table.insert(scope, new_sheet)

	local actual_properties = {
		Parent = properties.parent,

		[Derives] = properties.derives,
		[Rules] = properties.rules,
	}

	local tokens = properties.tokens

	if tokens then
		for name, value in tokens do
			actual_properties[Attribute(name)] = value
		end
	end

	applyProperties(scope, new_sheet, actual_properties)

	return new_sheet
end

return StyleSheet
