local instances = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local applyProperties = require "./applyProperties"
local defaultProperties = require "./defaultProperties"

local function New(
	scope: memory.Scope,
	classNameOrTemplate: string | Instance
): (props: instances.Properties) -> Instance
	local instance

	if typeof(classNameOrTemplate) == "Instance" then
		instance = classNameOrTemplate:Clone()

		if not instance then
			External.logError(
				"cannotCreateTemplate",
				nil,
				classNameOrTemplate:GetFullName()
			)
		end
	else
		local success, newInstance = pcall(Instance.new, classNameOrTemplate)

		if not success then
			External.logError("cannotCreateClass", nil, classNameOrTemplate)
		end

		local classProps = defaultProperties[classNameOrTemplate]

		if classProps then
			for key, value in classProps do
				newInstance[key] = value
			end
		end

		instance = newInstance
	end

	return function(props: instances.Properties): Instance
		table.insert(scope, instance)

		applyProperties(scope, instance, props)

		return instance
	end
end

return New
