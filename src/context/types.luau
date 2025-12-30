export type Contextual<T> = {
	type: "Contextual",

	now: (Contextual<T>) -> T,
	execute_with: <T, R, A...>(Contextual<T>, (A...) -> R, A...) -> R,
}
export type ContextConstructor = <T>(default: T) -> Contextual<T>

return nil
