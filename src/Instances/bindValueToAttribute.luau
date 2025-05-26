--!strict
local External = require "../External"
local Types = require "../Types"

local xtypeof = require "../Utility/xtypeof"

local function bindValueToAttribute(
	scope: Types.Scope,
	value: Types.Value<unknown>,
	instance: Instance,
	attribute: string
)
	if xtypeof(value) ~= "Value" then
		External.logError("expectedType", nil, "Value", typeof(value))
	end

	local event = instance:GetAttributeChangedSignal(attribute)

	value:set(instance:GetAttribute(attribute))

	table.insert(
		scope,
		event:Connect(function()
			value:set(instance:GetAttribute(attribute))
		end)
	)
end

return bindValueToAttribute
