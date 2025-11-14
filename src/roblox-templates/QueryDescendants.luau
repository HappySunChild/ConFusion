local instances = require "../roblox-instances/types"
local memory = require "../core-memory/types"
local templates = require "../roblox-templates/types"

local External = require "../core-external/External"

local applyProperties = require "../roblox-instances/applyProperties"

local function QueryDescendants(scope: memory.Scope, selector: string)
	return function(properties: instances.Properties)
		return function(parent: Instance): Instance?
			local descendants = parent:QueryDescendants(selector)
			local child = descendants[1]

			if child == nil then
				External.logErrorNonFatal(
					templates.missing_query_descendant,
					nil,
					selector
				)

				return nil
			end

			applyProperties(scope, child, properties)

			return child
		end
	end
end

return QueryDescendants
