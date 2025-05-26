local Types = require "../Types"

local change = require "../Graph/change"

local destructor = require "../Memory/destructor"

local isSimilar = require "../Utility/isSimilar"

type Self<V> = Types.Value<V>

local class = {
	type = "Value",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},
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

function class.set<V>(self: Self<V>, newValue: any)
	local currentValue = self._internalValue

	if not isSimilar(newValue, currentValue) then
		self._internalValue = newValue

		change(self)
	end

	return newValue
end

function class.update<V>(self: Self<V>, predicate)
	local currentValue = self._internalValue

	return self:set(predicate(currentValue))
end

function class._evaluate()
	return true
end

table.freeze(class)

return Value
