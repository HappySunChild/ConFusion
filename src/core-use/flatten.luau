local calc = require "../core-calc/types"

local castToState = require "../core-calc/castToState"

local function flatten<T>(use: calc.Use, target: calc.UsedAs<T>): T
	while castToState(target) ~= nil do
		target = use(target)
	end

	return target
end

return flatten
