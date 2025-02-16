local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local typeof = require(package.Utility.typeOf)

local keyCache = {}

local function Out(property: string): Types.SpecialKey
	local key = keyCache[property]

	if not key then
		key = table.freeze {
			kind = 'key',
			type = 'out',

			apply = function(scope: Types.Scope, applyTo: Instance, value: Types.Value<any>)
				if typeof(value) ~= 'value' then
					return error(`Invalid Out type.`, 2)
				end

				local event = applyTo:GetPropertyChangedSignal(property)

				table.insert(
					scope,
					event:Connect(function()
						value:set(applyTo[property])
					end)
				)

				return
			end,
		}

		keyCache[property] = key
	end

	return key
end

return Out
