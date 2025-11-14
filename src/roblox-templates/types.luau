local instances = require "../roblox-instances/types"
local memory = require "../core-memory/types"

export type FromTemplateConstructor = <InstanceT>(
	scope: memory.Scope,
	template: InstanceT
) -> (instances.Properties) -> InstanceT

export type OfChildConstructor = (
	scope: memory.Scope,
	name: string
) -> (instances.Properties) -> (parent: Instance) -> Instance?
export type OfClassConstructor = (
	scope: memory.Scope,
	class_name: string
) -> (instances.Properties) -> (parent: Instance) -> Instance?

return {
	cannot_create_template = "Unable to create template of instance '%s'.",

	missing_child = "Could not find child '%s' in '%s'.",
	missing_child_class = "Could not find child of class '%s' in '%s'.",
	missing_descendant = "Could not find descendant '%s' in '%s'.",
	missing_descendant_class = "Could not find descendant of class '%s' in '%s'.",
	missing_query_descendant = "Could not find descendants with query '%s'",
}
