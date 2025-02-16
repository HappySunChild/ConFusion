local package = script.Parent.Parent

local External = require(package.External)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local castToState = require(package.State.castToState)

local function observe<V>(target: Types.UsedAs<V>, callback: (V) -> (), immediate: boolean?)
	if not castToState(target) then
		return External.logErrorNonFatal('invalidObserveType', nil, typeof(target))
	end

	local observers = target[Symbols.Observers]

	if observers == nil then
		observers = {}

		target[Symbols.Observers] = observers
	end

	observers[callback] = true

	if immediate then
		External.doTaskImmediate(callback, target[Symbols.InternalValue])
	end

	return function()
		observers[callback] = nil
	end
end

return observe
