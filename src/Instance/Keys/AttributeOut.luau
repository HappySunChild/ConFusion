local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local typeof = require(package.Utility.typeOf)

local keyCache = {}

local function AttributeOut(attribute: string): Types.SpecialKey
	local key = keyCache[attribute]

	if not key then
		key = table.freeze {
			kind = 'key',
			type = 'out',

			apply = function(scope: Types.Scope, applyTo: Instance, value: Types.Value<any>)
				if typeof(value) ~= 'value' then
					return error(`Invalid Out type.`, 2)
				end

				local event = applyTo:GetAttributeChangedSignal(attribute)

				table.insert(
					scope,
					event:Connect(function()
						value:set(applyTo:GetAttribute(attribute))
					end)
				)

				return
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return AttributeOut
