local memory = require "../core-memory/types"

export type ExternalProvider = {
	startScheduler: () -> (),
	stopScheduler: () -> (),

	logErrorNonFatal: (message: string) -> (),
	logWarn: (message: string) -> (),

	doTaskImmediate: <A...>(resume: (A...) -> () | thread, A...) -> thread?,
	doTaskDeferred: <A...>(resume: (A...) -> () | thread, A...) -> thread?,
	doTaskDelayed: <A...>(sec: number, resume: (A...) -> () | thread, A...) -> thread?,
	cancelTask: (task: thread) -> boolean,
}

export type ExternalDebugger = {
	startDebugging: () -> (),
	stopDebugging: () -> (),

	trackScope: (scope: memory.Scope) -> (),
	untrackScope: (scope: memory.Scope) -> (),
}

return {
	missingProvider = "ConFusion is not connected to an external provider.",
}
