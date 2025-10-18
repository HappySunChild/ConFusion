local calc = require "../calc/types"
local memory = require "../memory/types"

export type AnimationCurve<V> = (elapsed: number) -> (boolean, V, ...any)
export type CurveGenerator<V> = (goal: V, start: V, ...any) -> AnimationCurve<V>

-- A state object whose value can be animated with a AnimatedMover callback.
export type Animated<V> = {
	type: "Animated",

	setDynamic: (self: Animated<V>, index: number, value: any) -> (),
	getDynamic: (self: Animated<V>, index: number) -> any?,
} & calc.StateObject<V>
export type AnimatedConstructor = <V>(
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	mover: calc.UsedAs<CurveGenerator<V>>
) -> Animated<V>

return {
	animatedInvalidGoal = "An Animated was given a NaN goal. Ensure NaN isn't being passed anywhere!\nGoal: '%*'",
	animatedInvalidMotion = "An Animated encountered NaN during motion. Ensure NaN/inf isn't being passed anywhere!\nCurrent: '%*'\nGoal: '%*'",
}
