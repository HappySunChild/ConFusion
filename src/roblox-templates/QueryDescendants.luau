local instances = require("../roblox-instances/types")
local memory = require("../core-memory/types")
local templates = require("../roblox-templates/types")

local External = require("../core-external/External")

local apply_properties = require("../roblox-instances/apply_properties")

local function QueryDescendants(
	scope: memory.Scope,
	selector: string,
	properties: instances.Properties
)
	return function(parent: Instance): Instance?
		local descendants = parent:QueryDescendants(selector)
		local child = descendants[1]

		if child == nil then
			External.log_error_nonfatal(templates.missing_query_descendant, nil, selector)

			return nil
		end

		apply_properties(scope, child, properties)

		return child
	end
end

return QueryDescendants
