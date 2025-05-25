--!strict
local External = require "../External"
local Types = require "../Types"

local xtypeof = require "../Utility/xtypeof"

-- mainly functions as a utility function, so you don't have to hydrate an instance with an `Out` property
-- again, im thinking of adding a `scope` parameter instead of returning a disconnect function.

-- it feels weird not also having a `bindValueToAttribute`, but i don't really want to make that aswell.. ughhh......
-- so much reduplication. have i truly been damned to integration hell?? lord have mercy on my miserable existance
-- maybe i should just give it up, remove this function and force the user to hydrate an instance so that they can bind some
-- values to properties/attributes. alternatively i could try to figure out a way to make this not as awful, maybe using some sort of 
-- shared function between `bindValueToProperty` and the `Out` key, so that i don't have to worry about inconsistent behavior between these 2 methods, which
-- should be identical to eachother.
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
