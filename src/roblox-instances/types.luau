local calc = require "../calc/types"
local memory = require "../memory/types"

export type SpecialKeyStage =
	"self"
	| "descendants"
	| "properties"
	| "ancestor"
	| "observer"
	| "last"

export type SpecialKey<T = string> = {
	type: T,
	kind: "key",
	stage: SpecialKeyStage,

	apply: (scope: memory.Scope, instance: Instance, value: any) -> (),
}

export type Properties = {
	[SpecialKey]: any,
}

export type Child =
	Instance
	| ((Instance) -> Instance?)
	| { Child }
	| calc.StateObject<Child>

export type NewConstructor = (
	scope: memory.Scope,
	classNameOrTemplate: string | Instance
) -> (Properties) -> Instance
export type HydrateConstructor = (
	scope: memory.Scope,
	instance: Instance
) -> (Properties) -> Instance
export type WithChildConstructor = (
	scope: memory.Scope,
	name: string
) -> (Properties) -> (parent: Instance) -> Instance?
export type WithChildOfClassConstructor = (
	scope: memory.Scope,
	className: string
) -> (Properties) -> (parent: Instance) -> Instance?

return nil
