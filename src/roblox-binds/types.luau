local calc = require "../calc/types"
local memory = require "../memory/types"

export type PropertyOf<V> = calc.StateObject<V> & {
	type: "PropertyOf",
}
export type AttributeOf<V> = calc.StateObject<V> & {
	type: "AttributeOf",
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
