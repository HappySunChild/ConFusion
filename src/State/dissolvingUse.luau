local Types = require "../Types"

local castToState = require "./castToState"

local function dissolvingUse<T>(target: Types.UsedAs<T>): T
	if castToState(target) then
		error "not-dissolvable"
	end

	return target
end

return dissolvingUse
