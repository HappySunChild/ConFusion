local calc = require "./types"
local memory = require "../core-memory/types"

local change = require "../core-graph/change"

local destructor = require "../core-memory/destructor"

local isSimilar = require "./isSimilar"

type Self<T> = calc.Value<T>

local class = table.freeze {
	type = "Value",
	kind = "state",
	timeliness = "lazy",

	_using = table.freeze {},

	set = function<T>(self: Self<T>, new_value: T): T
		if not isSimilar(new_value, self._internalValue) then
			self._internalValue = new_value

			change(self)
		end

		return new_value
	end,
	update = function<T>(self: Self<T>, updater: (T) -> T): T
		return self:set(updater(self._internalValue))
	end,
	_evaluate = function()
		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function Value<T>(scope: memory.Scope, initial_value: T): calc.Value<T>
	local newValue: Self<T> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_internalValue = initial_value,

		_users = {},
	}, METATABLE) :: any

	table.insert(scope, destructor(newValue))

	return newValue
end

return Value
