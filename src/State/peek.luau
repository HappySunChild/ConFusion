local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local castToState = require(script.Parent.castToState)
local evaluate = require(package.Graph.evaluate)

local function peek<T>(target: Types.StateObject<T> | T): T
	if castToState(target) then
		evaluate(target)

		return target[Symbols.Internal] :: T
	end

	return target :: T
end

return peek
