local calc = require "../core-calc/types"

local lerp_type = require "../lerp/lerp_type"

local function get_bounding_keys(
	eval_time: number,
	keyframes: { any }
): (number?, number?)
	local prev_time, next_time = nil, nil

	for keyframe_time in keyframes do
		if
			keyframe_time <= eval_time
			and (prev_time == nil or keyframe_time > prev_time)
		then
			prev_time = keyframe_time
		end

		if
			keyframe_time >= eval_time and (next_time == nil or keyframe_time < next_time)
		then
			next_time = keyframe_time
		end
	end

	return prev_time, next_time
end

local function evaluate_keyframes<T>(eval_time: number, keyframes: { T }, use: calc.Use): T?
	local prev_time, next_time = get_bounding_keys(eval_time, keyframes)

	if prev_time == next_time and prev_time ~= nil then -- if both times are exactly equal then that means we're exactly on a keyframe
		return use(keyframes[eval_time])
	end

	local prev_value, next_value = use(keyframes[prev_time]), use(keyframes[next_time])

	if prev_time ~= nil and next_time ~= nil then -- both bounding keys are present
		local intermediate_alpha = (eval_time - prev_time) / (next_time - prev_time)

		return lerp_type(prev_value, next_value, intermediate_alpha)
	elseif next_time == nil then -- open ended towards positive infinity
		return prev_value
	elseif prev_time == nil then -- open ended towards negative infinity
		return next_value
	end

	return nil -- neither keys were present, which means no keyframes were defined
end

return evaluate_keyframes
