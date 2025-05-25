--!strict
local External = require "../External"
local Types = require "../Types"

local xtypeof = require "../Utility/xtypeof"

-- mainly functions as a utility function, so you don't have to hydrate an instance with an `Out` property
local function bindValueToProperty(
	value: Types.Value<unknown>,
	instance: Instance,
	property: string
): () -> ()
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

	local connection = event:Connect(function()
		value:set((instance :: any)[property])
	end)

	table.insert(value.scope, connection)

	return function()
		connection:Disconnect()

		local index = table.find(value.scope, connection)

		if index then
			table.remove(value.scope, index)
		end
	end
end

return bindValueToProperty
