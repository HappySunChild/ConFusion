--!strict
local calc = require "../core-calc/types"
local memory = require "../core-memory/types"
local motion = require "../motion/types"
local tweens = require "./types"

local castToState = require "../core-calc/castToState"

local peek = require "../core-use/peek"

local Animated = require "../motion/Animated"

local getTweenAlpha = require "./getTweenAlpha"
local getTweenDuration = require "./getTweenDuration"
local lerp = require "./lerp"

local function tweenMover<V>(info: calc.UsedAs<tweens.TweenInfo>)
	return function(target: V, start: V): motion.AnimationCurve<V>
		local activeInfo = peek(info) :: tweens.TweenInfo
		local duration = getTweenDuration(activeInfo)

		-- tween stepper
		return function(elapsed: number): (boolean, V)
			local alpha = getTweenAlpha(activeInfo, elapsed)

			return elapsed >= duration, lerp(start, target, alpha)
		end
	end
end

local function Tween<V>(
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	info: calc.UsedAs<tweens.TweenInfo>
): motion.Animated<V> | V
	if castToState(goal) == nil then
		return goal
	end

	return Animated(scope, goal, tweenMover(info))
end

return Tween
