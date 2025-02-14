local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Observer = require(package.Graph.Observer)
local castToState = require(package.State.castToState)

local keyCache = {}

local function Attribute(attribute: string): Types.SpecialKey
	local key = keyCache[attribute]

	if not key then
		key = table.freeze {
			[Symbols.Kind] = 'key',
			[Symbols.Type] = 'attribute',

			apply = function(scope: Types.Scope, instance: Instance, value: Types.UsedAs<any>)
				if castToState(value) then
					Observer(scope, value):onBind(function(new)
						instance:SetAttribute(attribute, new)
					end)

					return
				end

				instance:SetAttribute(attribute, value)
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return Attribute
