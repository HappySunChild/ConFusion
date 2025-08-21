--!strict
local motion = require "../types"

local EasingStyles = require "./EasingStyles"

local class = table.freeze {
	type = "TweenInfo",
	kind = "tweeninfo",
}
local METATABLE = table.freeze { __index = class }

local function TweenInfo(info: {
	duration: number?,
	easingStyle: ((number) -> number)?,
	repeatCount: number?,
	reverses: boolean?,
	delayTime: number?,
}): motion.TweenInfo
	-- it truly pains me to have this in PascalCase, while everything else is in camelCase, but i really don't feel like
	-- rewriting getTweenDuration to support a single character difference
	-- this could probably be solved by just dropping support for Roblox's TweenInfo (or just converting it to our TweenInfo in the tweenMover)
	return setmetatable({
		Time = info.duration or 1,
		Easing = info.easingStyle or EasingStyles.Linear.Out,
		RepeatCount = info.repeatCount or 0,
		Reverses = info.reverses or false,
		DelayTime = info.delayTime or 0,
	}, METATABLE) :: any
end

return TweenInfo
