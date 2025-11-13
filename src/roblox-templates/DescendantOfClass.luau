local instances = require "../roblox-instances/types"
local memory = require "../core-memory/types"
local templates = require "./types"

local External = require "../core-external/External"

local applyProperties = require "../roblox-instances/applyProperties"

local function DescendantOfClass(scope: memory.Scope, class_name: string)
	return function(properties: instances.Properties)
		return function(parent: Instance)
			local child = parent:FindFirstChildWhichIsA(class_name, true)

			if child == nil then
				External.logErrorNonFatal(
					templates.missing_descendant_class,
					nil,
					class_name,
					parent.Name
				)

				return
			end

			applyProperties(scope, child, properties)

			return child
		end
	end
end

return DescendantOfClass
