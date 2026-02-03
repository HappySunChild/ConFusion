export type CleanupTask = any
export type Scope<T = any> = { CleanupTask } & T

export type Destroy = (CleanupTask) -> ()
export type Scoped = <T, M>(base: T, methods: M?) -> Scope<T & M>
export type Insert = <Tasks...>(scope: Scope, Tasks...) -> Tasks...

return {
	use_after_destroy = "%s is no longer valid - it was destroyed before %s.",

	destroyed_twice = "`destroy()` was given something that it is already cleaning up. Unclear how to proceed.",
	unknown_cleanup_task = "`destroy()` was given something it can't cleanup. Unclear how to proceed. (%*)",
}
