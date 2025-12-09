local calc = require "../../core-calc/types"
local match = require "../types"

local function Or(...: match.PredicatePattern)
	local all_predicates = { ... }

	return function(value: unknown, use: calc.Use)
		for _, predicate in all_predicates do
			local result = predicate(value, use)

			if result then
				return true
			end
		end

		return false
	end
end

return Or
