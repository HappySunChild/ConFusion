local instances = require "../roblox-instances/types"
local memory = require "../memory/types"

local External = require "../External"

local Hydrate = require "../roblox-instances/Hydrate"

local function FromTemplate<InstanceT>(
	scope: memory.Scope,
	template: InstanceT
): (props: instances.Properties) -> InstanceT
	template = template :: Instance
	local newInstance = template:Clone()

	if not newInstance then
		External.logError("cannotCreateTemplate", nil, template:GetFullName())
	end

	return Hydrate(scope, template)
end

return FromTemplate
