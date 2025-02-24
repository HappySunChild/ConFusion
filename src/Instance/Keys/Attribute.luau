local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local castToState = require(package.State.castToState)
local observe = require(package.Graph.observe)
local peek = require(package.State.peek)

local keyCache = {}

local function Attribute(attribute: string): Types.SpecialKey
	local key = keyCache[attribute]

	if not key then
		key = table.freeze {
			kind = 'key',
			type = 'attribute',

			apply = function(
				_: Types.Scope,
				applyTo: Instance,
				value: Types.UsedAs<any>
			)
				if castToState(value) then
					observe(value, function(new)
						applyTo:SetAttribute(attribute, new)
					end)
				end

				applyTo:SetAttribute(attribute, peek(value))
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return Attribute
