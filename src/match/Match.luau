local calc = require "../core-calc/types"
local logging = require "../core-logging/types"
local match = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local castToState = require "../core-calc/castToState"
local genericUse = require "../core-use/genericUse"
local isSimilar = require "../core-calc/isSimilar"
local parseError = require "../core-logging/parseError"

type Self<T> = {
	_literal_branches: { [any]: T },
	_state_branches: { [calc.StateObject<any>]: T },
	_predicate_branches: { [match.PatternPredicate]: T },
	_default_branch: T?,

	_input_value: calc.UsedAs<unknown>,

	_use: calc.Use,

	_match: (Self<T>, input_value: unknown) -> (boolean, T?),
} & match.Match<T>

local CLASS = table.freeze {
	type = "State",
	kind = "Match",
	timeliness = "lazy",

	_match = function<T>(self: Self<T>, input_value: unknown): (boolean, T?)
		local use = self._use

		for pattern, output_value in self._literal_branches do
			if isSimilar(pattern, input_value) then
				return true, output_value
			end
		end

		for pattern, output_value in self._state_branches do
			if isSimilar(use(pattern), input_value) then
				return true, output_value
			end
		end

		for pattern, output_value in self._predicate_branches do
			local ok, matched = xpcall(pattern, parseError, input_value, use)

			if not ok then
				External.logErrorNonFatal(
					match.pattern_predicate_error,
					matched :: logging.Error
				)

				continue
			end

			if matched == true then
				return true, output_value
			end
		end

		print "checking default"
		if self._default_branch ~= nil then
			return true, self._default_branch
		end

		return false
	end,
	_evaluate = function<T>(self: Self<T>)
		if self.scope == nil then
			return false
		end

		local input_value = self._use(self._input_value)
		local old_value = self._internal_value

		local did_match, new_value = self:_match(input_value)

		-- didn't match to any branches at all, match must be non-exhaustive
		if not did_match then
			External.logErrorNonFatal(
				match.match_not_exhaustive,
				nil,
				input_value,
				typeof(input_value)
			)

			return false
		end

		self._internal_value = new_value

		return not isSimilar(old_value, new_value)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function Match(
	scope: memory.Scope,
	input_value: calc.UsedAs<unknown>
): <T>({ [any]: T, _: T? }) -> match.Match<T>
	return function<T>(all_branches: { [any]: T, _: T? }): match.Match<T>
		local default_branch = all_branches._
		local literal_branches = {}
		local predicate_branches = {}
		local state_branches = {}

		for pattern, output_value in all_branches do
			if type(pattern) == "function" then
				predicate_branches[pattern] = output_value
			elseif castToState(pattern) ~= nil then
				state_branches[pattern] = output_value
			else
				literal_branches[pattern] = output_value
			end
		end

		local new_match: Self<T> = setmetatable({
			scope = scope,
			created_at = os.clock(),

			_input_value = input_value,

			_literal_branches = literal_branches,
			_state_branches = state_branches,
			_predicate_branches = predicate_branches,
			_default_branch = default_branch,

			_users = {},
			_using = {},
		}, METATABLE) :: any

		new_match._use = genericUse(new_match)

		return new_match
	end
end

return Match :: match.MatchConstructor
