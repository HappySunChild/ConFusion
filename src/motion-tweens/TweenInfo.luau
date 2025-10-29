local tweens = require "./types"

local EasingStyles = require "./EasingStyles"

local CLASS = table.freeze {
	type = "TweenInfo",
	kind = "tweeninfo",
}
local METATABLE = table.freeze { __index = CLASS }

local function TweenInfo(info: {
	easingStyle: ((number) -> number)?,
	time: number?,
	delayTime: number?,
	reverses: boolean?,
	repeatCount: number?,
}): tweens.TweenInfo
	return setmetatable({
		easing = info.easing_style or EasingStyles.Linear.Out,
		time = info.time or 1,
		delayTime = info.delay_time or 0,
		reverses = info.reverses or false,
		repeatCount = info.repeat_count or 0,
	}, METATABLE) :: any
end

return TweenInfo
