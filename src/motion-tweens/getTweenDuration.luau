local tweens = require "./types"

local function getTweenDuration(info: tweens.TweenInfo)
	if info.repeatCount == -1 then
		return math.huge
	end

	local duration = info.delayTime + info.time

	if info.reverses then
		duration += info.time
	end

	duration *= info.repeatCount + 1

	return duration
end

return getTweenDuration
