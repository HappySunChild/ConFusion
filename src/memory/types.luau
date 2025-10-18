export type CleanupTask = Instance | RBXScriptConnection | () -> () | { CleanupTask }
export type Scope<T = any> = { CleanupTask } & T
export type ScopedObject = {
	scope: Scope<unknown>?,
}

return {
	destroyedTwice = "`doCleanup()` was given something that it is already cleaning up. Unclear how to proceed.",
}
