--!strict
local calc = require "../calc/types"
local memory = require "../memory/types"
local motion = require "./types"

local castToState = require "../calc/castToState"

local peek = require "../use/peek"

local Animated = require "./Animated"

local getTweenAlpha = require "./tweening/getTweenAlpha"
local getTweenDuration = require "./tweening/getTweenDuration"
local lerp = require "./tweening/lerp"

local function tweenMover<V>(info: calc.UsedAs<motion.TweenInfo>)
	return function(target: V, start: V): motion.AnimationCurve<V>
		local activeInfo = peek(info) :: motion.TweenInfo
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
	info: calc.UsedAs<motion.TweenInfo>
): motion.Animated<V> | V
	if castToState(goal) == nil then
		return goal
	end

	return Animated(scope, goal, tweenMover(info))
end

return Tween
