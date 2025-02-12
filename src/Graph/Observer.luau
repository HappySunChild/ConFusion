local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local castToState = require(package.State.castToState)
local depend = require(script.Parent.depend)
local evaluate = require(script.Parent.evaluate)
local peek = require(package.State.peek)

local Observing = Symbols.named 'Observing'
local Listeners = Symbols.named 'Listeners'

local ObserverClass = {
	[Symbols.Type] = Types.Observer,
	[Symbols.Users] = table.freeze {},
}

local METATABLE = table.freeze { __index = ObserverClass }

local function Observer(target)
	local newObserver = setmetatable({
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.Using] = {},

		[Listeners] = {},
		[Observing] = castToState(target),
	}, METATABLE)

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
