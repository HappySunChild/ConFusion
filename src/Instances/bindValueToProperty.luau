--!strict
local External = require "../External"
local Types = require "../Types"

local xtypeof = require "../Utility/xtypeof"

local function bindValueToProperty(
	scope: Types.Scope,
	value: Types.Value<unknown>,
	instance: Instance,
	property: string
)
	if xtypeof(value) ~= "Value" then
		External.logError("expectedType", nil, "Value", typeof(value))
	end

	local ok, event = pcall(instance.GetPropertyChangedSignal, instance, property)

	if not ok then
		External.logError(
			"cannotConnectChange",
			nil,
			instance.ClassName,
			tostring(property)
		)
	end

	value:set((instance :: any)[property])

	table.insert(
		scope,
		event:Connect(function()
			value:set((instance :: any)[property])
		end)
	)
end

return bindValueToProperty
