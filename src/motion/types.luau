local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type AnimationCurve<T> = (elapsed: number) -> (boolean, T, ...any)
export type CurveGenerator<T> = (goal: T, start: T, ...any) -> AnimationCurve<T>

-- A state object whose value can be animated with a AnimatedMover callback.
export type Animated<T> = {
	type: "Animated",

	setDynamic: (self: Animated<T>, index: number, value: any) -> (),
	getDynamic: (self: Animated<T>, index: number) -> any?,
} & calc.StateObject<T>
export type AnimatedConstructor = <T>(
	scope: memory.Scope,
	goal: calc.UsedAs<T>,
	mover: calc.UsedAs<CurveGenerator<T>>
) -> Animated<T>

return {
	animated_invalid_goal = "An Animated was given a NaN goal. Ensure NaN isn't being passed anywhere!\nGoal: '%*'",
	animated_invalid_motion = "An Animated encountered NaN during motion. Ensure NaN/inf isn't being passed anywhere!\nCurrent: '%*'\nGoal: '%*'",
}
