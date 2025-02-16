local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local castToState = require(package.State.castToState)
local depend = require(script.Parent.depend)
local destructor = require(package.Memory.destructor)
local evaluate = require(script.Parent.evaluate)
local peek = require(package.State.peek)

local Listeners = Symbols.named 'Listeners'
local Observing = Symbols.named 'Observing'

local ObserverClass = {
	type = 'observer',
	kind = 'graph',
	[Symbols.Users] = table.freeze {},
}

local METATABLE = table.freeze { __index = ObserverClass }

local function Observer<V>(
	scope: Types.Scope,
	target: Types.UsedAs<V>
): Types.Observer<V>
	local newObserver = setmetatable({
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.Using] = {},

		[Listeners] = {},
		[Observing] = castToState(target),
	}, METATABLE)

	table.insert(scope, destructor(newObserver))

	evaluate(newObserver, true)

	return newObserver
end

function ObserverClass:onBind(callback)
	task.spawn(callback, peek(self[Observing]))

	return self:onChange(callback)
end

function ObserverClass:onChange(callback)
	local function disconnect()
		self[Listeners][callback] = nil
	end

	self[Listeners][callback] = true

	return disconnect
end

function ObserverClass:_evaluate()
	local target = self[Observing]

	if target then
		depend(self, target)
	end

	local newValue = peek(target)

	for callback in self[Listeners] do
		task.spawn(callback, newValue)
	end

	return true
end

table.freeze(ObserverClass)

return Observer
