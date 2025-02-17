local package = script.Parent.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local applyProperties = require(package.Instance.applyProperties)

local keyCache = {}

local function WithChild(childName: string): Types.SpecialKey
	local key = keyCache[childName]

	if not key then
		key = table.freeze {
			type = 'children',
			kind = 'key',

			apply = function(
				scope: Types.Scope,
				applyTo: Instance,
				properties: Types.Properties
			)
				local child = applyTo:FindFirstChild(childName)

				if not child then
					return External.logErrorNonFatal(
						'missingChild',
						nil,
						childName,
						applyTo.Name
					)
				end

				applyProperties(scope, child, properties)

				return
			end,
		}

		keyCache[childName] = key
	end

	return key
end

return WithChild
