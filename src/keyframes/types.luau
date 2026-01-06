local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type Keyframes<T> = calc.StateObject<T> & {
	type: "State",
	kind: "Keyframes",
}
export type KeyframesConstructor = <T>(
	scope: memory.Scope,
	alpha: calc.UsedAs<number>,
	keyframes: { [number]: T }
) -> Keyframes<T> | T

return nil
