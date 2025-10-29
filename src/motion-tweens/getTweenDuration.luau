local tweens = require "./types"

local function getTweenDuration(info: tweens.TweenInfo)
	if info.repeat_count == -1 then
		return math.huge
	end

	local duration = info.delay_time + info.time

	if info.reverses then
		duration += info.time
	end

	duration *= info.repeat_count + 1

	return duration
end

return getTweenDuration
