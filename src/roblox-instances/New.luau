local instances = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local Hydrate = require "./Hydrate"

local function New(
	scope: memory.Scope,
	class_name: string
): (instances.Properties) -> Instance
	local success, new_instance = pcall(Instance.new, class_name, nil) -- ok

	if not success then
		External.log_error(instances.cannot_create_class, nil, class_name)
	end

	return Hydrate(scope, new_instance)
end

return New
