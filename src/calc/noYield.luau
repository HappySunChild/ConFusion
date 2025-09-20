local doesYield = require "./doesYield"

local function yieldHandler<R...>(execOk: boolean, ...: R...): (boolean, boolean, R...)
	if not execOk then
		return false, false, ...
	end

	local yields: boolean, thread: thread = ...

	if yields then
		coroutine.close(thread)

		return true, true
	end

	return true, false, select(3, ...)
end

local function noYield<A..., R1..., R2...>(
	callback: (A...) -> R1...,
	errHandler: (string) -> R2...,
	...: A...
): (boolean, boolean, R1...)
	return yieldHandler(xpcall(doesYield, errHandler, callback, ...))
end

return noYield
