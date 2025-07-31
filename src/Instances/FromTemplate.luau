--!strict
local External = require "../External"
local Types = require "../Types"

local Hydrate = require "./Hydrate"

local function FromTemplate(
	scope: Types.Scope,
	template: Instance
): (props: Types.Properties) -> Instance
	local newInstance = template:Clone()

	if not newInstance then
		External.logError("cannotCreateTemplate", nil, template:GetFullName())
	end

	return Hydrate(scope, template)
end

return FromTemplate
