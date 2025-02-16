local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Computed = require(package.State.Computed)

local change = require(package.Graph.change)
local destructor = require(package.Memory.destructor)
local isSimilar = require(package.Utility.isSimilar)
local observe = require(package.Graph.observe)
local peek = require(package.State.peek)

local class = {
	kind = 'state',
	type = 'table',
	[Symbols.Using] = table.freeze {},
}

local METATABLE = table.freeze { __index = class }

local function Table<K, V>(scope: Types.Scope, value: { [K]: V }): Types.Table<K, V>
	local newTable = setmetatable({
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.InternalValue] = value,

		[Symbols.Users] = {},
	}, METATABLE)

	table.insert(scope, destructor(newTable))

	return newTable
end

function class:map(processor)
	return Computed(self[Symbols.Scope], function(use)
		return processor(use(self))
	end)
end

function class:onChange(callback)
	return observe(self, callback)
end

function class:setKey(key: any, newValue: any)
	local list = self[Symbols.InternalValue]
	local oldValue = list[key]

	list[key] = newValue

	if not isSimilar(oldValue, newValue) then
		change(self)
	end

	return list
end

function class:getKey(key: any)
	local list = peek(self)

	return list[key]
end

function class:remove(index: number)
	local list = self[Symbols.InternalValue]

	local removedValue = table.remove(list, index)

	change(self)

	return removedValue
end

function class:insert(index: number, value: any)
	local list = self[Symbols.InternalValue]

	table.insert(list, index, value)

	change(self)

	return value
end

function class:_evaluate()
	return true
end

table.freeze(class)

return Table
