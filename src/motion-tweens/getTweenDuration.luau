local tweens = require "./types"

local function getTweenDuration(tweenInfo: tweens.TweenInfo)
	if tweenInfo.repeat_count == -1 then
		return math.huge
	end

	local duration = tweenInfo.delay_time + tweenInfo.time

	if tweenInfo.reverses then
		duration += tweenInfo.time
	end

	duration *= tweenInfo.repeat_count + 1

	return duration
end

return getTweenDuration
