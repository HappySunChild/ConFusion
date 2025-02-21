local package = script.Parent.Parent

local Types = require(package.Types)

local Computed = require(package.State.Computed)
local peek = require(package.State.peek)

local change = require(package.Graph.change)
local observe = require(package.Graph.observe)

local destructor = require(package.Memory.destructor)

local isSimilar = require(package.Utility.isSimilar)

type Self<K, V> = Types.Table<K, V>

local class = {
	kind = "state",
	type = "table",
	_using = table.freeze {},
}

local METATABLE = table.freeze { __index = class }

local function Table<K, V>(scope: Types.Scope, value: { [K]: V }): Types.Table<K, V>
	local newTable = setmetatable({
		scope = scope,
		_createdAt = os.clock(),
		_internalValue = value,

		_users = {},
	}, METATABLE)

	table.insert(scope, destructor(newTable))

	return newTable
end

function class.map<V>(self: Self<V>, processor)
	return Computed(self.scope, function(use)
		return processor(use(self))
	end)
end

function class.onChange<V>(self: Self<V>, callback)
	return observe(self, callback)
end

function class.setKey<V>(self: Self<V>, key: any, newValue: any)
	local list = self._internalValue
	local oldValue = list[key]

	list[key] = newValue

	if not isSimilar(oldValue, newValue) then
		change(self)
	end

	return list
end

function class.getKey<V>(self: Self<V>, key: any)
	local list = peek(self)

	return list[key]
end

function class.remove<V>(self: Self<V>, index: number)
	local list = self._internalValue

	local removedValue = table.remove(list, index)

	change(self)

	return removedValue
end

function class.insert<V>(self: Self<V>, index: number, value: any)
	local list = self._internalValue

	table.insert(list, index, value)

	change(self)

	return value
end

function class._evaluate()
	return true
end

table.freeze(class)

return Table
