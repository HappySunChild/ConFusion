local calc = require "../core-calc/types"

local lerp = require "../motion-tweens/lerp"

local function find_bounding_keys(
	eval_alpha: number,
	keyframes: { any }
): (number?, number?)
	local low_key, high_key = -math.huge, math.huge

	for alpha_key in keyframes do
		if alpha_key <= eval_alpha and alpha_key > low_key then
			low_key = alpha_key
		end

		if alpha_key >= eval_alpha and alpha_key < high_key then
			high_key = alpha_key
		end
	end

	if low_key == -math.huge then
		low_key = nil
	end

	if high_key == math.huge then
		high_key = nil
	end

	return low_key, high_key
end

local function evaluate_sequence_at<T>(
	eval_alpha: number,
	keyframes: { T },
	use: calc.Use
): T?
	local prev_time, next_time = find_bounding_keys(eval_alpha, keyframes)

	if prev_time == next_time then -- if both times are exactly equal then that means we're exactly on a keyframe
		return use(keyframes[eval_alpha])
	end

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

return evaluate_sequence_at
