local instances = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local Hydrate = require "./Hydrate"
local defaultProperties = require "./defaultProperties"

local function New(
	scope: memory.Scope,
	className: string
): (props: instances.Properties) -> Instance
	local success, new_instance = pcall(Instance.new, className, nil) -- ok

	if not success then
		External.logError(instances.cannotCreateClass, nil, className)
	end

	local classProps = defaultProperties[className]

	if classProps then
		for key, value in classProps do
			new_instance[key] = value
		end
	end

	return Hydrate(scope, new_instance)
end

return New
