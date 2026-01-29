local calc = require "../core-calc/types"
local graph = require "../core-graph/types"
local memory = require "../core-memory/types"

export type Eventual<T> = {
	kind: "Eventual",
	timeliness: "lazy",

	is_pending: (Eventual<T>) -> boolean,
} & calc.StateNode<T>

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

export type Await = (scope: memory.Scope, subject: graph.GraphNode) -> ()

return {
	await_non_graph = "Can't await non-graph values.",
}
