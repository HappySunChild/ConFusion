local calc = require "../calc/types"
local memory = require "../memory/types"
local motion = require "./types"

local Animated = require "./Animated"
local getTweenAlpha = require "./getTweenAlpha"
local getTweenDuration = require "./getTweenDuration"
local lerp = require "./lerp"

local peek = require "../use/peek"

local function tweenMover(info: calc.UsedAs<TweenInfo>)
	return function(start: unknown, target: unknown)
		local activeInfo = peek(info)
		local duration = getTweenDuration(activeInfo)

		-- tween stepper
		return function(elapsed: number)
			local alpha = getTweenAlpha(activeInfo, elapsed)

			return elapsed >= duration, lerp(start, target, alpha)
		end
	end
end

local function Tween<V>(
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	info: calc.UsedAs<TweenInfo>
): motion.Animated<V>
	local tween = Animated(scope, goal, tweenMover(info))
	tween.name = "Tween"

	return tween
end

return Tween
