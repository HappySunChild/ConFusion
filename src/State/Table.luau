--!strict
local Types = require "../Types"

local peek = require "./peek"

local change = require "../Graph/change"

local destructor = require "../Memory/destructor"

local isSimilar = require "../Utility/isSimilar"

type Self<K, V> = Types.Table<K, V>

-- this whole object feels like it could've just been a user-made utility/wrapper
-- completely unnecessary. i don't even use this that often. why did i make this???

local class = table.freeze {
	type = "Table",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},

	setKey = function<K, V>(self: Self<K, V>, key: any, newValue: any)
		local list = self._internalValue
		local oldValue = list[key]

		list[key] = newValue

		if not isSimilar(oldValue, newValue) then
			change(self)
		end

		return list
	end,
	getKey = function<K, V>(self: Self<K, V>, key: any)
		local list = peek(self) :: any

		return list[key]
	end,
	remove = function<K, V>(self: Self<K, V>, index: number)
		local list = self._internalValue

		local removedValue = table.remove(list, index)

		change(self)

		return removedValue
	end,
	insert = function<K, V>(self: Self<K, V>, index: number, value: any)
		local list = self._internalValue

		table.insert(list, index, value)

		change(self)

		return value
	end,
	_evaluate = function()
		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function Table<K, V>(scope: Types.Scope, initialValue: { [K]: V }): Types.Table<K, V>
	local newTable: Self<K, V> = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = initialValue,

		_users = {},
	}, METATABLE) :: any

	table.insert(scope, destructor(newTable))

	return newTable
end

return Table
