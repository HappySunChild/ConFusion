--!strict
local motion = require "../types"

local EasingStyles = require "./EasingStyles"

local class = table.freeze {
	type = "TweenInfo",
	kind = "tweeninfo",
}
local METATABLE = table.freeze { __index = class }

local function TweenInfo(info: {
	easing_style: ((number) -> number)?,
	time: number?,
	delay_time: number?,
	reverses: boolean?,
	repeat_count: number?,
}): motion.TweenInfo
	return setmetatable({
		easing = info.easing_style or EasingStyles.Linear.Out,
		time = info.time or 1,
		delay_time = info.delay_time or 0,
		reverses = info.reverses or false,
		repeat_count = info.repeat_count or 0,
	}, METATABLE) :: any
end

return TweenInfo
