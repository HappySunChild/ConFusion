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
	) -> Pipe<O>,
}
export type PipeConstructor = <T>(
	scope: memory.Scope,
	initialValue: calc.UsedAs<T>
) -> Pipe<T>

return nil
