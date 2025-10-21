local instances = require "../roblox-instances/types"
local memory = require "../core-memory/types"
local templates = require "./types"

local External = require "../core-external/External"

local applyProperties = require "../roblox-instances/applyProperties"

local function OfName(scope: memory.Scope, name: string)
	return function(props: instances.Properties)
		return function(parent: Instance)
			local child = parent:FindFirstChild(name)

			if not child then
				External.logErrorNonFatal(templates.missingChild, nil, name, parent.Name)

				return
			end

			applyProperties(scope, child, props)

			return child
		end
	end
end

return OfName
