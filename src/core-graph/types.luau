local memory = require("../core-memory/types")

export type Validity =
	| "busy" -- currently reevaluating
	| "invalid" -- might need to be reevaluated
	| "dirty" -- definitely needs to be reevaluated
	| "valid" -- does not need to be reevaluated
export type Timeliness = "lazy" | "eager"

type Disconnect = () -> ()

export type GraphNode = {
	scope: memory.Scope?,

	type: "Graph",
	kind: string?,

	created_at: number?,
	validity: Validity?,
	timeliness: Timeliness,

	_last_change: number?,
	_last_compute: number?,
	_users: { [GraphNode]: true },
	_using: { [GraphNode]: true },
	_observers: { Disconnect }?,

	_evaluate: (GraphNode) -> boolean,
	_oldest_task: () -> (),
}

export type Observe = (
	scope: memory.Scope,
	subject: GraphNode,
	callback: () -> ()
) -> Disconnect?

return {
	infinite_loop = "Detected an infinite loop. Consider adding an explicit breakpoint to your code to prevent a cyclic dependency.",

	cannot_depend_dependency_frozen = "The user '%s' cannot depend on '%s', because the latter is frozen.",
	cannot_depend_user_frozen = "The user '%s' cannot depend on '%s', because the former is frozen.",
}
