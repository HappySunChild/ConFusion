--!strict
local Types = require "../Types"

local Animated = require "./Animated"
local getTweenAlpha = require "./getTweenAlpha"
local getTweenDuration = require "./getTweenDuration"
local lerp = require "./lerp"

local peek = require "../State/peek"

local function tweenMover(info: Types.UsedAs<TweenInfo | Types.TweenInfo>)
	return function(start: unknown, target: unknown)
		local activeInfo = peek(info) :: TweenInfo | Types.TweenInfo
		local duration = getTweenDuration(activeInfo)

		-- tween stepper
		return function(elapsed: number)
			local alpha = getTweenAlpha(activeInfo, elapsed)

			return elapsed >= duration, lerp(start, target, alpha)
		end
	end
end

local function Tween<V>(
	scope: Types.Scope,
	goal: Types.UsedAs<V>,
	info: Types.UsedAs<TweenInfo | Types.TweenInfo>
): Types.Animated<V>
	return Animated(scope, goal, tweenMover(info))
end

return Tween
