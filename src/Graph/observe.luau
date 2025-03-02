local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local function observe<V>(
	target: Types.StateObject<V>,
	callback: (V) -> (),
	immediate: boolean?
)
	if not castToState(target) then
		return External.logErrorNonFatal("invalidObserveType", nil, typeof(target))
	end

	local observers = target._observers

	if observers == nil then
		observers = {}

		target._observers = observers
	end

	observers[callback] = true

	if immediate then
		External.doTaskImmediate(callback, peek(target))
	end

	return function()
		observers[callback] = nil
	end
end

return observe
