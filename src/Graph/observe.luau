local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local castToState = require(package.State.castToState)

local function observe<V>(target: Types.UsedAs<V>, callback: (V) -> ())
	if not castToState(target) then
		return
	end

	local observers = target[Symbols.Observers]

	if observers == nil then
		observers = {}

		target[Symbols.Observers] = observers
	end

	observers[callback] = true

	return function()
		observers[callback] = nil
	end
end

return observe
