local calc = require "../core-calc/types"
local iter = require "../calc-iter/types"
local memory = require "../core-memory/types"
local tweens = require "../motion-tweens/types"

export type Pipe<S, T> = {
	type: "Pipe",
	kind: "pipe",

	spring: (
		Pipe<S, T>,
		speed: calc.UsedAs<number>?,
		damping: calc.UsedAs<number>?
	) -> Pipe<S, T>,
	tween: (Pipe<S, T>, info: calc.UsedAs<tweens.TweenInfo>) -> Pipe<S, T>,

	map: <O>(
		Pipe<S, T>,
		processor: (value: T, use: calc.Use, scope: memory.Scope<S>) -> O
	) -> Pipe<S, T>, -- Pipe<O>, -- this isn't allowed?

	forPairs: <IK, IV, OK, OV>(
		Pipe<S, T>,
		processor: iter.ForPairsProcessor<S, IK, IV, OK, OV>
	) -> Pipe<S, T>, -- Pipe<{ [OK]: OV }>,
	forValues: <IK, IV, OV>(
		Pipe<S, T>,
		processor: iter.ForValuesProcessor<S, IV, OV>
	) -> Pipe<S, T>, -- Pipe<{ [IK]: OV }>,
	forKeys: <IK, IV, OK>(
		Pipe<S, T>,
		processor: iter.ForKeysProcessor<S, IK, OK>
	) -> Pipe<S, T>, -- Pipe<{ [OK]: IV }>,

	resolve: (Pipe<S, T>) -> calc.UsedAs<T>,
}

export type PipeConstructor = <S, T>(
	scope: memory.Scope<S>,
	initial_value: calc.UsedAs<T>
) -> Pipe<S, T>

return nil
