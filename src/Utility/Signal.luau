local package = script.Parent.Parent

local Symbols = require(package.Symbols)

local Subscriptions = Symbols.named 'Subscriptions'

local class = {
	type = 'signal',
}

local METATABLE = table.freeze { __index = class }

local function Signal()
	local newSignal = setmetatable({
		[Subscriptions] = {},
	}, METATABLE)

	return newSignal
end

function class:fire(...)
	for callback in self[Subscriptions] do
		callback(...)
	end
end

function class:connect(callback)
	self[Subscriptions][callback] = true

	return function()
		self[Subscriptions][callback] = nil
	end
end

return Signal
