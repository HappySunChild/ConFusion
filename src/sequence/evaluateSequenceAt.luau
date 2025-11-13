local calc = require "../core-calc/types"

local lerp = require "../motion-tweens/lerp"

local findBoundingKeys = require "./findBoundingKeys"

local function evaluateSequenceAt<T>(eval_alpha: number, keyframes: { T }, use: calc.Use): T?
	local prev_time, next_time = findBoundingKeys(eval_alpha, keyframes)
	local prev_value, next_value = use(keyframes[prev_time]), use(keyframes[next_time])

	if prev_time ~= nil and next_time ~= nil then -- both bounding keys are present
		local intermediate_alpha = (eval_alpha - prev_time) / (next_time - prev_time)

		return lerp(prev_value, next_value, intermediate_alpha)
	elseif next_time == nil then -- open ended towards positive infinity
		return prev_value
	elseif prev_time == nil then -- open ended towards negative infinity
		return next_value
	end

	return nil -- neither keys were present, which means no keyframes were defined
end

return evaluateSequenceAt
