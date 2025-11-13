local calc = require "../core-calc/types"
local memory = require "../core-memory/types"
local sequence = require "./types"

local peek = require "../core-use/peek"

local depend = require "../core-graph/depend"

local castToState = require "../core-calc/castToState"
local isSimilar = require "../core-calc/isSimilar"

local lerp = require "../motion-tweens/lerp"

local getRangeKeys = require "./getRangeKeys"

type Self<T> = sequence.Sequence<T> & {
	_alpha: calc.UsedAs<number>,
	_keyframes: { [number]: T },
}

local CLASS = table.freeze {
	type = "State",
	kind = "Keyframes",
	timeliness = "lazy",

	_evaluate = function<T>(self: Self<T>)
		local alpha = self._alpha
		local keyframes = self._keyframes

		depend(self, castToState(alpha))

		local prev_time, next_time = getRangeKeys(peek(alpha), keyframes)
		local prev_value, next_value = keyframes[prev_time], keyframes[next_time]

		local new_value = nil

		if prev_time ~= nil and next_time ~= nil then
			local intermediate_alpha = (alpha - prev_time) / (next_time - prev_time)

			new_value = lerp(prev_value, next_value, intermediate_alpha)
		elseif next_time == nil then
			new_value = prev_value
		elseif prev_time == nil then
			new_value = next_value
		end

		local old_value = self._internal_value

		self._internal_value = new_value

		return isSimilar(old_value, new_value)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function Sequence<T>(
	scope: memory.Scope,
	alpha: calc.UsedAs<number>,
	keyframes: { [number]: T }
): sequence.Sequence<T>
	local new_keypoints = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_users = {},
		_using = {},

		_alpha = alpha,
		_keyframes = keyframes,
	}, METATABLE)

	return new_keypoints
end

return Sequence
