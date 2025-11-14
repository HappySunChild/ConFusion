local calc = require "../core-calc/types"
local logging = require "../core-logging/types"
local match = require "./types"

local External = require "../core-external/External"

local isSimilar = require "../core-calc/isSimilar"

local peek = require "../core-use/peek"

local parseError = require "../core-logging/parseError"

local function checkPredicate(
	predicate: match.PredicatePattern,
	input_value: unknown,
	use: calc.Use
): boolean
	if type(predicate) ~= "function" then
		return false
	end

	local ok, matched = xpcall(predicate, parseError, input_value, use)

	if not ok then
		External.logError(match.predicate_pattern_error, matched :: logging.Error)
	end

	return matched :: boolean
end

local function matchBranches<T>(
	input_value: unknown,
	use: calc.Use,
	default: T?,
	...: { [any]: T }
): (boolean, T?)
	for _, branches in { ... } do
		for pattern, output_value in branches do
			if isSimilar(peek(pattern), input_value) then
				use(pattern) -- this feels a little gross, but it's fine really

				return true, output_value
			elseif checkPredicate(pattern, input_value, use) then
				return true, output_value
			end
		end
	end

	if default ~= nil then
		return true, default
	end

	return false, nil
end

return matchBranches
