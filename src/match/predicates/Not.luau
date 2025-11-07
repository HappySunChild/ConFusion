local calc = require "../../core-calc/types"
local match = require "../types"

local function Not(predicate: match.PatternPredicate)
	return function(value: unknown, use: calc.Use)
		return not predicate(value, use)
	end
end

return Not
