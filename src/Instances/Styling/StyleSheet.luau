--!strict
local Types = require "../../Types"

local applyStyleTokens = require "./applyStyleTokens"

local function Sheet(scope: Types.Scope, props: Types.StyleSheetProperties)
	local derives = props.Derives
	local rules = props.Rules
	local tokens = props.Tokens

	local newSheet = Instance.new "StyleSheet"

	if props.Name then
		newSheet.Name = props.Name
	end

	table.insert(scope, newSheet)

	if derives then
		newSheet:SetDerives(derives)
	end

	if rules then
		for priority, rule in rules do
			newSheet:InsertStyleRule(rule, priority)
		end
	end

	if tokens then
		applyStyleTokens(newSheet, tokens)
	end

	newSheet.Parent = props.Parent

	return newSheet
end

return Sheet
