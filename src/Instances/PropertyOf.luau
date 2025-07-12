local External = require "../External"
local Types = require "../Types"

local destructor = require "../Memory/destructor"

local change = require "../Graph/change"

local class = table.freeze {
	type = "Property",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},

	_evaluate = function()
		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function PropertyOf(scope: Types.Scope, instance: Instance, property: string)
	local ok, event = pcall(instance.GetPropertyChangedSignal, instance, property)

	if not ok then
		External.logError(
			"cannotConnectChange",
			nil,
			instance.ClassName,
			tostring(property)
		)
	end

	local newProperty = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},

		_internalValue = instance[property],
	}, METATABLE)

	table.insert(scope, {
		destructor(newProperty),
		event:Connect(function()
			newProperty._internalValue = instance[property]

			change(newProperty)
		end),
	})

	return newProperty
end

return PropertyOf
