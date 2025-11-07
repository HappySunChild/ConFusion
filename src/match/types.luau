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

return {
	pattern_predicate_error = "Error in pattern predicate:\nERROR_MESSAGE",
	match_not_exhaustive = "Non-exhaustive match pattern: `%*` (%*) not covered!",
}
