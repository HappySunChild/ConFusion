local calc = require "./types"
local memory = require "../core-memory/types"

local change = require "../core-graph/change"

local destroy_node = require "../core-memory/destroy_node"

local is_similar = require "./is_similar"

type Self<T> = calc.Value<T>

local CLASS = table.freeze {
	type = "State",
	kind = "Value",
	timeliness = "lazy",

	_using = table.freeze {},

	set = function<T>(self: Self<T>, new_value: T): T
		if not is_similar(new_value, self._internal_value) then
			self._internal_value = new_value

			change(self)
		end

		return new_value
	end,
	update = function<T>(self: Self<T>, updater: (T) -> T): T
		return self:set(updater(self._internal_value))
	end,
	_evaluate = function()
		return true
	end,
	destroy = destroy_node,
}
local METATABLE = table.freeze { __index = CLASS }

local function Value<T>(scope: memory.Scope, initial_value: T): calc.Value<T>
	local new_value: Self<T> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_internal_value = initial_value,

		_users = {},
	}, METATABLE) :: any

	table.insert(scope, new_value)

	return new_value
end

return Value
