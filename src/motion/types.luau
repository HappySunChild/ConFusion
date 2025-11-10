local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type AnimationMove<T> = (elapsed: number) -> (boolean, T, ...any)
export type MoveGenerator<T> = (goal: T, start: T, ...any) -> AnimationMove<T>

export type Motion<T> = {
	kind: "Animated",

	setDynamic: (self: Motion<T>, index: number, value: any) -> (),
	getDynamic: (self: Motion<T>, index: number) -> any?,
} & calc.StateObject<T>
export type MotionConstructor = <T>(
	scope: memory.Scope,
	goal: calc.UsedAs<T>,
	move_generator: calc.UsedAs<MoveGenerator<T>>
) -> Motion<T>

return {
	animated_invalid_goal = "An Animated was given a NaN goal. Ensure NaN isn't being passed anywhere!\nGoal: '%*'",
	animated_invalid_motion = "An Animated encountered NaN during motion. Ensure NaN/inf isn't being passed anywhere!\nCurrent: '%*'\nGoal: '%*'",
}
