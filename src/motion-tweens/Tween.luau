local calc = require "../core-calc/types"
local memory = require "../core-memory/types"
local motion = require "../motion/types"
local tweens = require "./types"

local cast_to_state = require "../core-calc/cast_to_state"

local peek = require "../core-use/peek"

local Motion = require "../motion/Motion"

local getTweenAlpha = require "./getTweenAlpha"
local getTweenDuration = require "./getTweenDuration"
local lerp = require "./lerp"

local function TweenMover<T>(info: calc.UsedAs<tweens.TweenInfo>)
	local curve_generator = function(target: T, start: T): motion.AnimationMove<T>
		local active_info = peek(info) :: tweens.TweenInfo
		local duration = getTweenDuration(active_info)

		local new_curve = function(elapsed: number): (boolean, T)
			local alpha = getTweenAlpha(active_info, elapsed)

			return elapsed >= duration, lerp(start, target, alpha)
		end

		return new_curve
	end

	return curve_generator
end

local function Tween<T>(
	scope: memory.Scope,
	goal: calc.UsedAs<T>,
	info: calc.UsedAs<tweens.TweenInfo>
): motion.Motion<T> | T
	if cast_to_state(goal) == nil then
		return goal
	end

	return Motion(scope, goal, TweenMover(info))
end

return Tween
