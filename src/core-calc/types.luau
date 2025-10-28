local graph = require "../core-graph/types"
local memory = require "../core-memory/types"

export type StateObject<T> = {
	_internalValue: T,

	kind: "state",
	type: string,
} & graph.GraphObject

export type UsedAs<T> = T | StateObject<T>
export type Use = <T>(target: UsedAs<T>) -> T

-- A state object whose value can be set by the user at any time.
export type Value<T> = {
	type: "Value",
	timeliness: "lazy",

	set: (Value<T>, newValue: T) -> T,
	update: (Value<T>, predicate: (T) -> T) -> T,
} & StateObject<T>
export type ValueConstructor = <T>(scope: memory.Scope, initialValue: T) -> Value<T>

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = {
	type: "Computed",
	timeliness: "eager",
} & StateObject<T>

export type ComputedProcessor<S, T> = (use: Use, scope: memory.Scope<S>) -> T
export type ComputedConstructor = <S, T>(
	scope: memory.Scope<S>,
	processor: ComputedProcessor<S, T>
) -> Computed<T> | T

return nil
