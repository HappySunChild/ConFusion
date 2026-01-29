local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type PropertyOf<T> = { kind: "PropertyOf" } & calc.StateNode<T>
export type AttributeOf<T> = { kind: "AttributeOf" } & calc.StateNode<T>

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
