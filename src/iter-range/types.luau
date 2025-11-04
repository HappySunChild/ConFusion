local calc = require "../core-calc/types"
local iter = require "../iter/types"
local memory = require "../core-memory/types"

export type Range = {
	type: "Range",
	timeliness: "lazy",
} & calc.StateObject<{ number }>
export type RangeConstructor = (
	scope: memory.Scope,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	step: calc.UsedAs<number>?
) -> Range | { number }

return nil
