local doesYield = require "./doesYield"

local parseError = require "../logging/parseError"

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

local function noYield<A..., R...>(callback: (A...) -> R..., ...: A...): (boolean, boolean, R...)
	return yieldHandler(xpcall(doesYield, parseError, callback, ...))
end

return noYield
