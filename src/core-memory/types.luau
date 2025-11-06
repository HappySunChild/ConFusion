export type CleanupTask = Instance | RBXScriptConnection | () -> () | { CleanupTask }
export type Scope<T = any> = { CleanupTask } & T

export type DoCleanup = (CleanupTask) -> ()
export type DeriveScope = <T, M>(base: Scope<T>, methods: M?) -> Scope<T & M>
export type Scoped = <T, M>(base: T, methods: M?) -> Scope<T & M>
export type Insert = <Tasks...>(scope: Scope, Tasks...) -> Tasks...

return {
	destroyed_twice = "`doCleanup()` was given something that it is already cleaning up. Unclear how to proceed.",
}
