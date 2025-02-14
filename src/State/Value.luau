local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Computed = require(package.State.Computed)
local Observer = require(package.Graph.Observer)

local change = require(package.State.change)
local destructor = require(package.Memory.destructor)
local isSimilar = require(package.Utility.isSimilar)

local class = {
	[Symbols.Kind] = 'state',
	[Symbols.Type] = 'value',
	[Symbols.Using] = table.freeze {},
}

local METATABLE = table.freeze { __index = class }

local function Value<V>(scope, initialValue: V, debugId): Types.Value<V>
	local newValue = setmetatable({
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),

		[Symbols.InternalValue] = initialValue,
		[Symbols.DebugId] = debugId,

		[Symbols.Users] = {},
	}, METATABLE)

	table.insert(scope, destructor(newValue))

	return newValue
end

function class:onChange(callback)
	local observer = Observer(self[Symbols.Scope], self)

	return observer:onChange(callback), observer
end

function class:set(newValue: any)
	local currentValue = self[Symbols.InternalValue]

	self[Symbols.InternalValue] = newValue

	if not isSimilar(newValue, currentValue) then
		change(self)
	end

	return newValue
end

function class:update(predicate)
	local currentValue = self[Symbols.InternalValue]

	return self:set(predicate(currentValue))
end

function class:map(processor)
	return Computed(self[Symbols.Scope], function(use)
		return processor(use(self))
	end, `Computed({self[Symbols.DebugId]})`)
end

function class:bindToInstanceProperty(instance: Instance, property: string)
	local success = pcall(function()
		return instance[property]
	end)

	if not success then
		error(`'{property}' is not a valid property of instance '{instance}'`, 2)
	end

	self:set(instance[property])

	local connection = instance:GetPropertyChangedSignal(property):Connect(function()
		self:set(instance[property])
	end)

	table.insert(self[Symbols.Scope], connection)

	return function()
		connection:Disconnect()
	end, connection
end

function class:_evaluate()
	return true
end

table.freeze(class)

return Value
