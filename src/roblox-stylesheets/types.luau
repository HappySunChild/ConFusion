local calc = require "../calc/types"
local memory = require "../memory/types"

export type StyleRuleProperties = {
	rules: { [number]: StyleRule }?,
	[string]: calc.UsedAs<any>,
}

export type StyleSheetProperties = {
	derives: { StyleSheet }?,
	rules: { [number]: StyleRule }?,
	tokens: { [string]: any }?,

	parent: Instance?,
}

export type StyleRuleConstructor = (
	scope: memory.Scope,
	selector: string
) -> (StyleRuleProperties) -> StyleRule

export type StyleSheetConstructor = (
	scope: memory.Scope,
	properties: StyleSheetProperties
) -> StyleSheet

return nil
