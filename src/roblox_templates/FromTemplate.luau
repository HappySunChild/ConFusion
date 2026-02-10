local instances = require("../roblox_instances/types")
local memory = require("../core_memory/types")
local templates = require("./types")

local External = require("../core_external/External")

local Hydrate = require("../roblox_instances/Hydrate")

local function FromTemplate<InstanceT>(
	scope: memory.Scope,
	template: InstanceT,
	properties: instances.Properties
): InstanceT
	template = template :: Instance

	local new_instance = template:Clone()

	if new_instance == nil then
		External.log_error(
			if template.Archivable
				then templates.cannot_clone_template
				else templates.cannot_clone_template_unarchivable,
			nil,
			template.ClassName,
			template:GetFullName()
		)
	end

	return Hydrate(scope, template, properties)
end

return FromTemplate
