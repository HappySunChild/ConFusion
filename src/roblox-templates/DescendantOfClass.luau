local instances = require "../roblox-instances/types"
local memory = require "../memory/types"
local templates = require "./types"

local External = require "../external/External"

local applyProperties = require "../roblox-instances/applyProperties"

local function DescendantOfClass(scope: memory.Scope, className: string)
	return function(props: instances.Properties)
		return function(parent: Instance)
			local child = parent:FindFirstChildWhichIsA(className, true)

			if not child then
				External.logErrorNonFatal(
					templates.missingDescendantClass,
					nil,
					className,
					parent.Name
				)

				return
			end

			applyProperties(scope, child, props)

			return child
		end
	end
end

return DescendantOfClass
