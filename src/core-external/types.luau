local memory = require "../core-memory/types"

export type ExternalProvider = {
	start_scheduler: () -> (),
	stop_scheduler: () -> (),

	log_error_nonfatal: (message: string) -> (),
	log_warn: (message: string) -> (),

	do_task_immediate: <A...>(resume: (A...) -> () | thread, A...) -> thread?,
	do_task_deferred: <A...>(resume: (A...) -> () | thread, A...) -> thread?,
	do_task_delayed: <A...>(sec: number, resume: (A...) -> () | thread, A...) -> thread?,
	cancel_task: (task: thread) -> boolean,
}

export type ExternalDebugger = {
	start_debugging: () -> (),
	stop_debugging: () -> (),

	track_scope: (scope: memory.Scope) -> (),
	untrack_scope: (scope: memory.Scope) -> (),
}

return {
	missing_provider = "ConFusion is not connected to an external provider.",
}
