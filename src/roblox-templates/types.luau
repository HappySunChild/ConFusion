local instances = require "../roblox-instances/types"
local memory = require "../memory/types"

export type FromTemplateConstructor = <InstanceT>(
	scope: memory.Scope,
	template: InstanceT
) -> (instances.Properties) -> InstanceT

export type WithChildConstructor = (
	scope: memory.Scope,
	name: string
) -> (instances.Properties) -> (parent: Instance) -> Instance?
export type WithChildOfClassConstructor = (
	scope: memory.Scope,
	className: string
) -> (instances.Properties) -> (parent: Instance) -> Instance?

return nil
