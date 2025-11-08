local calc = require "../../core-calc/types"
local match = require "../types"

local function And(...: match.PredicatePattern)
	local all_predicates = { ... }

	return function(value: unknown, use: calc.Use)
		for _, predicate in all_predicates do
			local result = predicate(value, use)

			if not result then
				return false
			end
		end

		return true
	end
end

return And
