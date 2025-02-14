local package = script.Parent.Parent

local Symbols = require(package.Symbols)

local Subscriptions = Symbols.named 'Subscriptions'

local SignalClass = {
	[Symbols.Type] = 'signal',
}

local METATABLE = table.freeze { __index = SignalClass }

local function Signal()
	local newSignal = setmetatable({
		[Subscriptions] = {},
	}, METATABLE)

	return newSignal
end

function SignalClass:fire(...)
	for callback in self[Subscriptions] do
		callback(...)
	end
end

function SignalClass:connect(callback)
	self[Subscriptions][callback] = true

	return function()
		self[Subscriptions][callback] = nil
	end
end

return Signal
