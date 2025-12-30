local calc = require "../core-calc/types"

local cast_to_state = require "../core-calc/cast_to_state"

local function dissolving_use<T>(target: calc.UsedAs<T>): T
	if cast_to_state(target) ~= nil then
		error "not-dissolvable"
	end

	return target
end

return dissolving_use
