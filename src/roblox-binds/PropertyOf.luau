local binds = require "./types"
local instances = require "../roblox-instances/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local change = require "../core-graph/change"

local generic_destroy = require "../core-memory/generic_destroy"

type Self<T> = binds.PropertyOf<T> & {
	_event: RBXScriptConnection,
}

local CLASS = table.freeze {
	type = "State",
	kind = "PropertyOf",
	timeliness = "lazy",
	_using = table.freeze {},

	_evaluate = function()
		return true
	end,
	destroy = function<T>(self: Self<T>)
		self._event:Disconnect()

		generic_destroy(self)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function PropertyOf(
	scope: memory.Scope,
	instance: Instance,
	property: string
): binds.PropertyOf<unknown>
	local ok, event: RBXScriptSignal =
		pcall(instance.GetPropertyChangedSignal, instance, property)

	if not ok then
		External.log_error(
			instances.cannot_connect_change,
			nil,
			instance.ClassName,
			tostring(property)
		)
	end

	local new_property: binds.PropertyOf<unknown> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_users = {},

		_internal_value = instance[property],
		_event = nil,
	}, METATABLE) :: any
	new_property._event = event:Connect(function()
		new_property._internal_value = instance[property]

		change(new_property)
	end)

	table.insert(scope, new_property)

	return new_property
end

return PropertyOf
