local calc = require "../core-calc/types"
local memory = require "../core-memory/types"
local motion = require "../motion/types"
local tweens = require "./types"

local Animated = require "../motion/Animated"
local castToState = require "../core-calc/castToState"
local getTweenAlpha = require "./getTweenAlpha"
local getTweenDuration = require "./getTweenDuration"
local lerp = require "./lerp"
local peek = require "../core-use/peek"

local function tweenMover<T>(info: calc.UsedAs<tweens.TweenInfo>)
	return function(target: T, start: T): motion.AnimationCurve<T>
		local active_info = peek(info) :: tweens.TweenInfo
		local duration = getTweenDuration(active_info)

		-- tween stepper
		return function(elapsed: number): (boolean, T)
			local alpha = getTweenAlpha(active_info, elapsed)

			return elapsed >= duration, lerp(start, target, alpha)
		end
	end
end

local function Tween<T>(
	scope: memory.Scope,
	goal: calc.UsedAs<T>,
	info: calc.UsedAs<tweens.TweenInfo>
): motion.Animated<T> | T
	if castToState(goal) == nil then
		return goal
	end

	return Animated(scope, goal, tweenMover(info))
end

return Tween
