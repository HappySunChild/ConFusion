local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type Match<T> = {
	kind: "Match",
	timeliness: "lazy",
} & calc.StateObject<T>
export type MatchConstructor = <T>(
	scope: memory.Scope,
	value: calc.UsedAs<unknown>
) -> (patterns: { [any]: T, _: T? }) -> Match<T>

export type PatternPredicate = (value: unknown, use: calc.Use) -> boolean
export type MatchPredicates = {
	Not: (predicate: PatternPredicate) -> PatternPredicate,
	And: (...PatternPredicate) -> PatternPredicate,
	Or: (...PatternPredicate) -> PatternPredicate,

	OfType: (target_type: calc.UsedAs<string>) -> PatternPredicate,
	Nil: PatternPredicate,
	NaN: PatternPredicate,

	Regex: (regex_pattern: calc.UsedAs<string>) -> PatternPredicate,

	Equals: (other: calc.UsedAs<any>) -> PatternPredicate,
	GreaterThan: (minimum: calc.UsedAs<number>) -> PatternPredicate,
	LessThan: (maximum: calc.UsedAs<number>) -> PatternPredicate,
	InRange: (
		minimum: calc.UsedAs<number>,
		maximum: calc.UsedAs<number>
	) -> PatternPredicate,
}

return {
	pattern_predicate_error = "Error in pattern predicate:\nERROR_MESSAGE",
	match_not_exhaustive = "Non-exhaustive match pattern: `%*` (%*) not covered!",
}
