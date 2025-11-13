local calc = require "../core-calc/types"
local memory = require "../core-memory/types"
local sequence = require "./types"

local dissolvingUse = require "../core-use/dissolvingUse"
local genericUse = require "../core-use/genericUse"

local castToState = require "../core-calc/castToState"
local isSimilar = require "../core-calc/isSimilar"

local evaluateSequenceAt = require "./evaluateSequenceAt"

type Self<T> = sequence.Sequence<T> & {
	_alpha: calc.UsedAs<number>,
	_keyframes: { T },

	_use: calc.Use,
}

local CLASS = table.freeze {
	type = "State",
	kind = "Keyframes",
	timeliness = "lazy",

	_evaluate = function<T>(self: Self<T>): boolean
		if self.scope == nil then
			return false
		end

		local use = self._use

		local new_value = evaluateSequenceAt(use(self._alpha), self._keyframes, use)
		local old_value = self._internal_value

		self._internal_value = new_value

		return isSimilar(old_value, new_value)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function checkDissolvable<T>(
	alpha: calc.UsedAs<number>,
	keyframes: { T }
): (boolean, T?)
	if castToState(alpha) ~= nil then
		return false, nil
	end

	local ok, value = pcall(evaluateSequenceAt, alpha :: number, keyframes, dissolvingUse)

	if not ok then
		return false, nil
	end

	return true, value
end

local function Sequence<T>(
	scope: memory.Scope,
	alpha: calc.UsedAs<number>,
	keyframes: { T }
): sequence.Sequence<T> | T
	local can_dissolve, constant = checkDissolvable(alpha, keyframes)

	if can_dissolve then
		return constant
	end

	local new_sequence: Self<T> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_users = {},
		_using = {},

		_alpha = alpha,
		_keyframes = keyframes,
	}, METATABLE) :: any

	new_sequence._use = genericUse(new_sequence)

	return new_sequence
end

return Sequence
