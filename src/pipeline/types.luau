local calc = require "../calc/types"
local memory = require "../memory/types"

export type Pipe<T> = calc.StateObject<T> & {
	type: "Pipe",

	spring: (
		Pipe<T>,
		speed: calc.UsedAs<number>?,
		damping: calc.UsedAs<number>?
	) -> Pipe<T>,
	tween: (Pipe<T>, info: calc.UsedAs<TweenInfo>) -> Pipe<T>,

	map: <O>(
		Pipe<T>,
		processor: (value: T, use: calc.Use, scope: memory.Scope) -> O
	) -> Pipe<T>, -- Pipe<O>, -- this isn't allowed?

	forPairs: <IK, IV, OK, OV>(
		Pipe<T>,
		processor: calc.ForPairsProcessor<unknown, IK, IV, OK, OV>
	) -> Pipe<T>, -- Pipe<{ [OK]: OV }>,
	forValues: <IK, IV, OV>(
		Pipe<T>,
		processor: calc.ForValuesProcessor<unknown, IV, OV>
	) -> Pipe<T>, -- Pipe<{ [IK]: OV }>,
	forKeys: <IK, IV, OK>(
		Pipe<T>,
		processor: calc.ForKeysProcessor<unknown, IK, OK>
	) -> Pipe<T>, -- Pipe<{ [OK]: IV }>,

	finish: (Pipe<T>) -> calc.StateObject<T>,
}

export type PipeConstructor = <T>(
	scope: memory.Scope,
	initialValue: calc.UsedAs<T>
) -> Pipe<T>

return nil
