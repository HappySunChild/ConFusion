local Types = require "../Types"

local change = require "../Graph/change"

local destructor = require "../Memory/destructor"

local isSimilar = require "../Utility/isSimilar"

type Self<V> = Types.Value<V>

local class = table.freeze {
	type = "Value",
	kind = "state",
	timeliness = "lazy",

	_using = table.freeze {},

	set = function<V>(self: Self<V>, newValue: any)
		if not isSimilar(newValue, self._internalValue) then
			self._internalValue = newValue

			change(self)
		end

		return newValue
	end,
	update = function<V>(self: Self<V>, updater: (V) -> any): any
		return self:set(updater(self._internalValue))
	end,
	_evaluate = function()
		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function Value<V>(scope: Types.Scope, initialValue: V): Types.Value<V>
	local newValue: Self<V> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_internalValue = initialValue,

		_users = {},
	}, METATABLE) :: any

	table.insert(scope, destructor(newValue))

	return newValue
end

return Value
