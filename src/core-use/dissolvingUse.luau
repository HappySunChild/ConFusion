local calc = require "../core-calc/types"

local castToState = require "../core-calc/castToState"

local function dissolvingUse<T>(target: calc.UsedAs<T>): T
	if castToState(target) ~= nil then
		error "not-dissolvable"
	end

	return target
end

return dissolvingUse
