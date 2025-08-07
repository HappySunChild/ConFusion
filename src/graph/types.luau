local memory = require "../memory/types"

export type Validity = "busy" | "invalid" | "valid"
export type Timeliness = "lazy" | "eager"

export type GraphObject = {
	type: string?,
	kind: string?,

	createdAt: number?,
	validity: Validity?,
	timeliness: Timeliness,

	_lastChange: number?,
	_lastCompute: number?,
	_users: { [GraphObject]: true },
	_using: { [GraphObject]: true },
	_observers: { [{}]: () -> () }?,

	_evaluate: (GraphObject) -> boolean,
} & memory.ScopedObject

-- An object which can listen for updates on another state object.
export type Observer = {
	type: "Observer",
	kind: "graph",

	onBind: (Observer, callback: () -> ()) -> () -> (),
	onChange: (Observer, callback: () -> ()) -> () -> (),
} & GraphObject
export type ObserverConstructor = (scope: memory.Scope, subject: GraphObject) -> Observer

return nil
