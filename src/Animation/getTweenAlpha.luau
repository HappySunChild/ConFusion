--!strict
local Types = require "../Types"

local function getTweenAlpha(info: Types.TweenInfo | TweenInfo, currentTime: number)
	local cycleCount = info.RepeatCount + 1
	local cycleDuration = info.DelayTime + info.Time

	if info.Reverses then
		cycleDuration += info.Time
	end

	if currentTime == math.huge then
		return 1
	end

	if currentTime >= cycleDuration * cycleCount and cycleCount > 0 then
		return 1
	end

	local cycleTime = currentTime % cycleDuration

	if cycleTime < info.DelayTime then
		return 0
	end

	local tweenProgress = (cycleTime - info.DelayTime) / info.Time

	if tweenProgress > 1 then
		tweenProgress = 2 - tweenProgress
	end

	-- something about this feels wrong...
	-- almost unstable...
	-- probably nothing!
	if typeof(info) == "TweenInfo" then
		-- she's a hack, but it's sort of necessary
		-- getting TweenService at the top of the file would crash if you tried to run this in a different runtime
		return game:GetService("TweenService")
			:GetValue(tweenProgress, info.EasingStyle, info.EasingDirection)
	end

	return (info :: Types.TweenInfo).Easing(tweenProgress)
end

return getTweenAlpha
