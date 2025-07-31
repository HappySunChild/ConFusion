local calc = require "../calc/types"
local memory = require "../memory/types"

export type Eventual<T> = {
	type: "Eventual",
	timeliness: "lazy",

	isPending: (Eventual<T>) -> boolean,
} & calc.StateObject<T>
export type EventualConstructor = <S, T>(
	scope: memory.Scope<S>,
	processor: (calc.Use, memory.Scope<S>) -> T,
	pendingValue: T
) -> Eventual<T>

return nil
