local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local keyCache = {}

local function OnChange(property: string)
	local key = keyCache[property]

	if not key then
		key = table.freeze {
			[Symbols.Type] = 'onChange',
			[Symbols.Kind] = 'key',

			apply = function(scope: Types.Scope, instance: Instance, callback: (value: any) -> ())
				local event = instance:GetPropertyChangedSignal(property)

				table.insert(
					scope,
					event:Connect(function()
						callback(instance[property])
					end)
				)
			end,
		}

		keyCache[property] = key
	end

	return key
end

return OnChange
