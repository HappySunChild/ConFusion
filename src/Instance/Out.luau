local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local outCache = {}

local function Out(property: string)
	local key = outCache[property]

	if not key then
		key = table.freeze {
			[Symbols.Type] = Types.Out,
			[Symbols.Kind] = Kinds.Key,

			apply = function(instance: Instance, value: Types.Value<any>)
				if Types.of(value) ~= Types.Value then
					return error(`Invalud Out type.`, 2)
				end

				value:bindToInstanceProperty(instance, property)
			end,
		}

		outCache[property] = key
	end

	return key
end

return Out
