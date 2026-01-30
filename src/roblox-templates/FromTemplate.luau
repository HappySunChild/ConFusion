local instances = require("../roblox-instances/types")
local memory = require("../core-memory/types")
local templates = require("./types")

local External = require("../core-external/External")

local Hydrate = require("../roblox-instances/Hydrate")

local function FromTemplate<InstanceT>(
	scope: memory.Scope,
	template: InstanceT,
	properties: instances.Properties
): InstanceT
	template = template :: Instance

	local new_instance = template:Clone()

	if new_instance == nil then
		External.log_error(templates.cannot_create_template, nil, template:GetFullName())
	end

	return Hydrate(scope, template, properties)
end

return FromTemplate
