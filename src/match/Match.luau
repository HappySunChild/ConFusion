local calc = require "../core-calc/types"
local logging = require "../core-logging/types"
local match = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local dissolvingUse = require "../core-use/dissolvingUse"
local genericUse = require "../core-use/genericUse"

local castToState = require "../core-calc/castToState"
local isSimilar = require "../core-calc/isSimilar"

local parseError = require "../core-logging/parseError"

local None = require "./None"
local matchBranches = require "./matchBranches"
local partitionBranches = require "./partitionBranches"

type Self<T> = {
	_default_branch: T?,
	_branch_categories: { { [any]: T } },

	_input_value: calc.UsedAs<unknown>,

	_use: calc.Use,

	_match: (Self<T>, input_value: unknown) -> (boolean, T?),
} & match.Match<T>

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
		local old_value = self._internal_value

		local ok, did_match: boolean | logging.Error, new_value: T? = xpcall(
			matchBranches,
			parseError,
			input_value,
			use,
			self._default_branch,
			unpack(self._branch_categories)
		)

		if not ok then
			External.logErrorNonFatal(match.matching_error, did_match :: logging.Error)

			return false
		end

		-- didn't match to any branches at all, match must be non-exhaustive
		if did_match == false then
			External.logErrorNonFatal(
				match.match_not_exhaustive,
				nil,
				input_value,
				typeof(input_value)
			)

			return false
		end

		-- this is disgusting
		if new_value == None then
			new_value = nil
		end

		self._internal_value = new_value

		return not isSimilar(old_value, new_value)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function checkDissolvable<T>(
	input_value: calc.UsedAs<unknown>,
	default_branch: T?,
	...: { [any]: T }
): (boolean, T?)
	if castToState(input_value) ~= nil then
		return false, nil
	end

	local ok, did_match, new_value =
		pcall(matchBranches, input_value, dissolvingUse, default_branch, ...)

	if not ok or not did_match then
		return false
	end

	return true, new_value
end

local function Match<T>(
	scope: memory.Scope,
	input_value: calc.UsedAs<unknown>,
	all_branches: { [any]: T, _: T? }
): match.Match<T> | T
	local default_branch, branch_categories = partitionBranches(all_branches)

	local can_dissolve, constant =
		checkDissolvable(input_value, default_branch, unpack(branch_categories))

	if can_dissolve then
		return constant
	end

	local new_match: Self<T> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_input_value = input_value,

		_default_branch = default_branch,
		_branch_categories = branch_categories,

		_users = {},
		_using = {},
	}, METATABLE) :: any

	new_match._use = genericUse(new_match)

	return new_match
end

return Match :: match.MatchConstructor
