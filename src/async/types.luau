local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type Eventual<T> = {
	type: "Eventual",
	timeliness: "lazy",

	isPending: (Eventual<T>) -> boolean,
} & calc.StateObject<T>

export type EventualProcessor<S, T> = (
	use: calc.Use,
	scope: memory.Scope<S>,
	become: (T) -> ()
) -> ()
export type EventualConstructor = <S, T>(
	scope: memory.Scope<S>,
	processor: EventualProcessor<S, T>,
	pending_value: T
) -> Eventual<T>

return {
	awaitNonGraph = "Can't await non-graph values.",
}
