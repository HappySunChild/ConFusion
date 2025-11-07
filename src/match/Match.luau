local calc = require "../core-calc/types"
local logging = require "../core-logging/types"
local match = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local genericUse = require "../core-use/genericUse"
local isSimilar = require "../core-calc/isSimilar"
local parseError = require "../core-logging/parseError"

type Self<T> = {
	_input_value: calc.UsedAs<unknown>,
	_patterns: { [any]: T },
	_default: T?,

	_use: calc.Use,
} & match.Match<T>

local function checkPattern(pattern: any, input_value: unknown, use: calc.Use): boolean
	if use(pattern) == input_value then
		return true
	end

	if type(pattern) == "function" then
		local ok, result: logging.Error | boolean =
			xpcall(pattern, parseError, input_value, use)

		if not ok then
			External.logErrorNonFatal(match.pattern_predicate_error, result)
		end

		return result and ok
	end

	return false
end

local CLASS = table.freeze {
	type = "State",
	kind = "Match",
	timeliness = "lazy",

	_evaluate = function<T>(self: Self<T>)
		if self.scope == nil then
			return false
		end

		local use = self._use

		local input_value = use(self._input_value)

		local patterns = self._patterns

		local old_value = self._internal_value
		local new_value = self._default

		local did_match = new_value ~= nil

		for pattern, pattern_value in patterns do
			local matched = checkPattern(pattern, input_value, use)

			if matched then
				did_match = true
				new_value = pattern_value

				break
			end
		end

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
	return function<T>(patterns: { [any]: T, _: T? }): match.Match<T>
		local c_patterns = table.clone(patterns)
		local default = c_patterns._

		c_patterns._ = nil

		local new_match: Self<T> = setmetatable({
			scope = scope,
			created_at = os.clock(),

			_input_value = input_value,
			_patterns = c_patterns,
			_default = default,

			_users = {},
			_using = {},
		}, METATABLE) :: any

		new_match._use = genericUse(new_match)

		return new_match
	end
end

return Match :: match.MatchConstructor
