local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local Observer = require(package.Graph.Observer)
local castToState = require(package.State.castToState)

local keyCache = {}

local function Attribute(attribute: string): Types.SpecialKey
	local key = keyCache[attribute]

	if not key then
		key = table.freeze {
			kind = 'key',
			type = 'attribute',

			apply = function(scope: Types.Scope, applyTo: Instance, value: Types.UsedAs<any>)
				if castToState(value) then
					Observer(scope, value):onBind(function(new)
						applyTo:SetAttribute(attribute, new)
					end)

					return
				end

				applyTo:SetAttribute(attribute, value)
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return Attribute
