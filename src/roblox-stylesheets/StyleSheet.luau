local memory = require "../core-memory/types"
local style = require "./types"

local StyleDerives = require "./keys/StyleDerives"
local StyleRules = require "./keys/StyleRules"

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

		[StyleDerives] = properties.derives,
		[StyleRules] = properties.rules,
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
