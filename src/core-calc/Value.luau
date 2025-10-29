local calc = require "./types"
local memory = require "../core-memory/types"

local change = require "../core-graph/change"
local destructor = require "../core-memory/destructor"
local isSimilar = require "./isSimilar"

type Self<T> = calc.Value<T>

local CLASS = table.freeze {
	type = "Value",
	kind = "state",
	timeliness = "lazy",

	_using = table.freeze {},

	set = function<T>(self: Self<T>, new_value: T): T
		if not isSimilar(new_value, self._internal_value) then
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
}
local METATABLE = table.freeze { __index = CLASS }

local function Value<T>(scope: memory.Scope, initial_value: T): calc.Value<T>
	local new_value: Self<T> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_internal_value = initial_value,

		_users = {},
	}, METATABLE) :: any

	table.insert(scope, destructor(new_value))

	return new_value
end

return Value
