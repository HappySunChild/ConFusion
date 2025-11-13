local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type Sequence<T> = calc.StateObject<T> & {
	type: "State",
	kind: "Keyframes",
}
export type SequenceConstructor = <T>(
	scope: memory.Scope,
	alpha: calc.UsedAs<number>,
	keyframes: { [number]: T }
) -> Sequence<T> | T

return nil
