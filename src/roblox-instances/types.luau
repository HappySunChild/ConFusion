local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

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

export type Properties = { [any]: any }
export type Child =
	Instance
	| ((Instance) -> Instance?)
	| { Child }
	| calc.StateObject<Child>

export type NewConstructor = (
	scope: memory.Scope,
	class_name: string
) -> (Properties) -> Instance
export type HydrateConstructor = <InstanceT>(
	scope: memory.Scope,
	instance: InstanceT
) -> (Properties) -> InstanceT

return {
	cannotCreateClass = "Unable to create instance of type '%s'.",
	cannotConnectChange = "The %s class doesn't have a property called '%s'.",
	cannotConnectEvent = "The %s class doesn't have a event called '%s'.",

	propertyInvalidType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
	propertyCannotAssign = "The %s class has no assignable property '%s'.",
	propertyAssignError = "Error while setting property:\nERROR_MESSAGE",

	invalidChildType = "Invalid child type '%s'.",

	missingSpecialKeyStage = "The SpecialKey '%s' is missing a stage property.",
	invalidSpecialKeyStage = "The SpecialKey '%s' has an invalid stage '%s'.",

	expectedType = "Expected a %s, got %s.",
}
