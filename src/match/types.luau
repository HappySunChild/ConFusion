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

export type PredicatePattern = (value: unknown, use: calc.Use) -> boolean
export type MatchPredicates = {
	Not: (predicate: PredicatePattern) -> PredicatePattern,
	And: (...PredicatePattern) -> PredicatePattern,
	Or: (...PredicatePattern) -> PredicatePattern,

	OfType: (target_type: calc.UsedAs<string>) -> PredicatePattern,
	Nil: PredicatePattern,
	NaN: PredicatePattern,

	Regex: (regex_pattern: calc.UsedAs<string>) -> PredicatePattern,

	Equals: (other: calc.UsedAs<any>) -> PredicatePattern,
	GreaterThan: (minimum: calc.UsedAs<number>) -> PredicatePattern,
	LessThan: (maximum: calc.UsedAs<number>) -> PredicatePattern,
	InRange: (
		minimum: calc.UsedAs<number>,
		maximum: calc.UsedAs<number>
	) -> PredicatePattern,
}

return {
	pattern_predicate_error = "Error in pattern predicate:\nERROR_MESSAGE",
	match_not_exhaustive = "Non-exhaustive match pattern: `%*` (%*) not covered!",
}
