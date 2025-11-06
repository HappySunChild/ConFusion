export type CleanupTask = Instance | RBXScriptConnection | () -> () | { CleanupTask }
export type Scope<T = any> = { CleanupTask } & T

return {
	destroyed_twice = "`doCleanup()` was given something that it is already cleaning up. Unclear how to proceed.",
}
