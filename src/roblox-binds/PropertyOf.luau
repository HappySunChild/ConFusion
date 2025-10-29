local binds = require "./types"
local instances = require "../roblox-instances/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local change = require "../core-graph/change"
local destructor = require "../core-memory/destructor"

local CLASS = table.freeze {
	type = "PropertyOf",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},

	_evaluate = function()
		return true
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
		External.logError(
			instances.cannotConnectChange,
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
	}, METATABLE) :: any

	table.insert(scope, {
		destructor(new_property),
		event:Connect(function()
			new_property._internal_value = instance[property]

			change(new_property)
		end),
	})

	return new_property
end

return PropertyOf
