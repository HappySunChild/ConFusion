local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local keyCache = {}

local function OnChange(property: string)
	local key = keyCache[property]

	if not key then
		key = table.freeze {
			type = 'onChange',
			kind = 'key',

			apply = function(scope: Types.Scope, applyTo: Instance, callback: (any) -> ())
				local event = applyTo:GetPropertyChangedSignal(property)

				table.insert(
					scope,
					event:Connect(function()
						callback(applyTo[property])
					end)
				)
			end,
		}

		keyCache[property] = key
	end

	return key
end

return OnChange
