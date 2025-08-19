local function yieldingHandler<R...>(
	thread: thread,
	ok: boolean,
	...: R...
): (boolean, thread, R...)
	if ok == false then
		error(debug.traceback(thread, ...), 3)
	end

	if coroutine.status(thread) == "suspended" then
		return true, thread
	end

	return false, thread, ...
end

local function doesYield<A..., R...>(callback: (A...) -> R..., ...: A...): (boolean, thread, R...)
	local thread = coroutine.create(callback)

	return yieldingHandler(thread, coroutine.resume(thread, ...))
end

return doesYield
