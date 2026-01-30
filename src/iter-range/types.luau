local calc = require("../core-calc/types")
local iter = require("../iter/types")
local memory = require("../core-memory/types")

export type Range = {
	kind: "Range",
	timeliness: "lazy",
} & calc.StateNode<{ number }>
export type RangeConstructor = (
	scope: memory.Scope,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	step: calc.UsedAs<number>?
) -> Range | { number }

export type RangePair<T> = {
	invalidate_index: (RangePair<T>, new_index: number) -> (),
} & calc.StateNode<T>

export type RangeDisassemblyProcessor<S, T> = (
	use: calc.Use,
	scope: memory.Scope<S>,
	index: number
) -> T
export type ForRangeConstructor = <S, T>(
	scope: memory.Scope<S>,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	processor: RangeDisassemblyProcessor<S, T>,
	step: calc.UsedAs<number>?
) -> iter.Iter<number, T>

return nil
