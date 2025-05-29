--!strict
local Types = require "../../Types"

local EasingStyles = require "./EasingStyles"

local class = {
	type = "TweenInfo",
	kind = "tweeninfo",
}
local METATABLE = table.freeze { __index = class }

local function TweenInfo(info: {
	Duration: number?,
	EasingStyle: ((number) -> number)?,
	RepeatCount: number?,
	Reverses: boolean?,
	DelayTime: number?,
}): Types.TweenInfo
	local newTweenInfo = setmetatable({
		Time = info.Duration or 1,
		Easing = info.EasingStyle or EasingStyles.Quad.Out,
		RepeatCount = info.RepeatCount or 0,
		Reverses = info.Reverses or false,
		DelayTime = info.DelayTime or 0,
	}, METATABLE) :: Types.TweenInfo

	return newTweenInfo
end

return TweenInfo
