local motion = require "../types"

local function getTweenAlpha(info: motion.TweenInfo, currentTime: number)
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

	-- this horrific nonsense kind of makes me want to drop support for Roblox's TweenInfo, but we must persevere...
	if typeof(info) == "TweenInfo" then
		info = info :: TweenInfo

		local TweenService = game:GetService "TweenService"

		return TweenService:GetValue(
			tweenProgress,
			info.EasingStyle,
			info.EasingDirection
		)
	end

	return info.Easing(tweenProgress)
end

return getTweenAlpha
