local calc = require "../core-calc/types"
local memory = require "../core-memory/types"
local motion = require "../motion/types"

export type TweenConstructor = <T>(
	scope: memory.Scope,
	goal: calc.UsedAs<T>,
	info: calc.UsedAs<TweenInfo>
) -> motion.Animated<T> | T

export type EasingStyle = {
	read Out: (number) -> number,
	read In: (number) -> number,
	read InOut: (number) -> number,
}

export type EasingStyles = {
	read Constant: EasingStyle,
	read Linear: EasingStyle,
	read Exponential: EasingStyle,
	read Circular: EasingStyle,
	read Sine: EasingStyle,

	read Back: EasingStyle,
	read Elastic: EasingStyle,

	read Quad: EasingStyle,
	read Cubic: EasingStyle,
	read Quart: EasingStyle,
	read Quint: EasingStyle,

	read new: {
		read Exponent: (exponent: number) -> EasingStyle,
		read Overshoot: (amplitude: number) -> EasingStyle,
		read Elastic: (period: number) -> EasingStyle,
	},
}

-- not to be confused with TweenInfo, this is TweenInfo. got that?
export type TweenInfo = {
	type: "TweenInfo",
	kind: "tweeninfo",

	easingStyle: (number) -> number,
	time: number,
	delayTime: number,
	reverses: boolean,
	repeatCount: number,
}
export type TweenInfoConstructor = (
	info: {
		easingStyle: ((number) -> number)?,
		time: number?,
		delayTime: number?,
		reverses: boolean?,
		repeatCount: number?,
	}
) -> TweenInfo

return nil
