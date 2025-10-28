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
	cannotCreateTemplate = "Unable to create template of instance '%s'.",

	missingChild = "Could not find child '%s' in '%s'.",
	missingChildClass = "Could not find child of class '%s' in '%s'.",
	missingDescendant = "Could not find descendant '%s' in '%s'.",
	missingDescendantClass = "Could not find descendant of class '%s' in '%s'.",
}
