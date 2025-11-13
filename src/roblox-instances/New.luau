local instances = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local Hydrate = require "./Hydrate"
local defaultProperties = require "./defaultProperties"

local function New(
	scope: memory.Scope,
	class_name: string
): (instances.Properties) -> Instance
	local success, new_instance = pcall(Instance.new, class_name, nil) -- ok

	if not success then
		External.logError(instances.cannot_create_class, nil, class_name)
	end

	local default_class_properties = defaultProperties[class_name]

	if default_class_properties ~= nil then
		for key, value in default_class_properties do
			new_instance[key] = value
		end
	end

	return Hydrate(scope, new_instance)
end

return New
