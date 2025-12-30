local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type PropertyOf<T> = calc.StateObject<T> & {
	kind: "PropertyOf",
}
export type AttributeOf<T> = calc.StateObject<T> & {
	kind: "AttributeOf",
}

export type PropertyOfConstructor = (
	scope: memory.Scope,
	instance: Instance,
	property: string
) -> PropertyOf<unknown>
export type AttributeOfConstructor = (
	scope: memory.Scope,
	instance: Instance,
	attribute: string
) -> AttributeOf<unknown>

return nil
