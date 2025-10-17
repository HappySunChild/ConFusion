local calc = require "../calc/types"
local instances = require "../roblox-instances/types"
local memory = require "../memory/types"

export type WithChildConstructor = (
	scope: memory.Scope,
	name: string
) -> (instances.Properties) -> (parent: Instance) -> Instance?
export type WithChildOfClassConstructor = (
	scope: memory.Scope,
	className: string
) -> (instances.Properties) -> (parent: Instance) -> Instance?

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
