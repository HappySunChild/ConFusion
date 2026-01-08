local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type SpecialKeyStage =
	| "self"
	| "descendants"
	| "properties"
	| "ancestor"
	| "observer"
	| "last"

export type SpecialKey<T = string> = {
	type: "SpecialKey",
	kind: T,
	stage: SpecialKeyStage,

	apply: (scope: memory.Scope, instance: Instance, value: unknown) -> (),
}

export type Properties = { [any]: any }
export type Child = Instance | ((Instance) -> Child?) | { Child } | calc.StateNode<Child>

export type NewConstructor = (
	scope: memory.Scope,
	class_name: string
) -> (Properties) -> Instance
export type HydrateConstructor = <InstanceT>(
	scope: memory.Scope,
	instance: InstanceT
) -> (Properties) -> InstanceT

return {
	cannot_create_class = "Unable to create instance of type '%s'.",
	cannot_connect_change = "The %s class doesn't have a property called '%s'.",
	cannot_connect_event = "The %s class doesn't have a event called '%s'.",

	property_invalid_type = "'%s.%s' expected a '%s' type, but got a '%s' type.",
	property_cannot_assign = "The %s class has no assignable property '%s'.",
	property_assign_error = "Error while setting property:\nERROR_MESSAGE",

	invalid_key_type = "Invalid key type '%s'.",
	invalid_child_type = "Invalid child type '%s'.",

	missing_specialkey_stage = "The SpecialKey '%s' is missing a stage property.",
	invalid_specialkey_stage = "The SpecialKey '%s' has an invalid stage '%s'.",

	expected_type = "Expected a %s, got %s.",
}
