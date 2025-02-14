local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local typeof = require(package.Utility.typeOf)

local keyCache = {}

local function Out(property: string): Types.SpecialKey
	local key = keyCache[property]

	if not key then
		key = table.freeze {
			[Symbols.Kind] = 'key',
			[Symbols.Type] = 'out',

			apply = function(_: Types.Scope, instance: Instance, value: Types.Value<any>)
				if typeof(value) ~= Types.Value then
					return error(`Invalid Out type.`, 2)
				end

				value:bindToInstanceProperty(instance, property)

				return
			end,
		}

		keyCache[property] = key
	end

	return key
end

return Out
