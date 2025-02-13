local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local outCache = {}

local function Out(property: string): Types.SpecialKey
	local key = outCache[property]

	if not key then
		key = table.freeze {
			[Symbols.Kind] = Kinds.Key,
			[Symbols.Type] = Types.Out,

			apply = function(_: Types.Scope, instance: Instance, value: Types.Value<any>)
				if Types.of(value) ~= Types.Value then
					return error(`Invalid Out type.`, 2)
				end

				value:bindToInstanceProperty(instance, property)
				
				return
			end,
		}

		outCache[property] = key
	end

	return key
end

return Out
