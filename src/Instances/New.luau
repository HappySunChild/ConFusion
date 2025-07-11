local External = require "../External"
local Types = require "../Types"

local Hydrate = require "./Hydrate"

local defaultProperties = require "./defaultProperties"

local function New<T>(
	scope: Types.Scope<T>,
	className: string
): (props: Types.Properties) -> Instance
	local success, newInstance = pcall(Instance.new, className)

	if not success then
		External.logError("cannotCreateClass", nil, className)
	end

	local classProps = defaultProperties[className]

	if classProps then
		for key, value in classProps do
			newInstance[key] = value
		end
	end

	return Hydrate(scope, newInstance :: Instance)
end

return New
