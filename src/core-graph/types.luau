local memory = require "../core-memory/types"

export type Validity = "busy" | "invalid" | "valid"
export type Timeliness = "lazy" | "eager"

type Disconnect = () -> ()

export type GraphObject = {
	scope: memory.Scope?,

	type: "Graph",
	kind: string?,

	created_at: number?,
	validity: Validity?,
	timeliness: Timeliness,

	_last_change: number?,
	_last_compute: number?,
	_users: { [GraphObject]: true },
	_using: { [GraphObject]: true },
	_observers: { Disconnect }?,

	_evaluate: (GraphObject) -> boolean,
	destroy: (GraphObject) -> (),
}

export type Observe = (
	scope: memory.Scope,
	subject: GraphObject,
	callback: () -> ()
) -> Disconnect?

return {
	infinite_loop = "Detected an infinite loop. Consider adding an explicit breakpoint to your code to prevent a cyclic dependency.",

	cannot_depend = "%s (%s) cannot depend on %s (%s).",

	invalid_evaluate_type = "Invalid evaluate argument, got '%s'.",
	invalid_change_type = "Can't change non-state value, got '%s'.",
}
