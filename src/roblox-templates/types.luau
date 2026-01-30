local instances = require("../roblox-instances/types")
local memory = require("../core-memory/types")

export type FromTemplateConstructor = <InstanceT>(
	scope: memory.Scope,
	template: InstanceT
) -> (instances.Properties) -> InstanceT

export type QueryDescendants = (
	scope: memory.Scope,
	selector: string,
	properties: instances.Properties
) -> (parent: Instance) -> Instance?

return {
	cannot_create_template = "Unable to create template of instance '%s'.",

	missing_query_descendant = "Could not find descendants with query '%s'",
}
