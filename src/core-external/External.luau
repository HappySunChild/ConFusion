local external = require "./types"
local logging = require "../core-logging/types"

local formatError = require "../core-logging/formatError"

local bound_callbacks = {}
local active_provider: external.ExternalProvider? = nil

local last_update = os.clock()
local delta_time = 0

local function logError(message: string, err: logging.Error?, ...: any?): never
	error(formatError(message, err, ...), 0)
end

local External = table.freeze {
	setProvider = function(new_provider: external.ExternalProvider?)
		local old_provider = active_provider

		if old_provider ~= nil then
			old_provider.stopScheduler()
		end

		active_provider = new_provider

		if new_provider then
			new_provider.startScheduler()
		end

		return old_provider
	end,
	bindToUpdateStep = function(callback: (now: number) -> ()): () -> ()
		local unique_identifier = {}
		bound_callbacks[unique_identifier] = callback

		return function()
			bound_callbacks[unique_identifier] = nil
		end
	end,
	performUpdateStep = function(): ()
		local now = os.clock()

		delta_time = now - last_update
		last_update = now

		for _, callback in bound_callbacks do
			callback(now)
		end
	end,

	getDeltaTime = function(): number
		return delta_time
	end,
	getLastUpdate = function(): number
		return last_update
	end,

	doTaskImmediate = function<A...>(resume: (A...) -> () | thread, ...: A...): thread?
		if not active_provider then
			logError(external.missingProvider)
		end

		return active_provider.doTaskImmediate(resume, ...)
	end,
	doTaskDeferred = function<A...>(resume: (A...) -> () | thread, ...: A...): thread?
		if not active_provider then
			logError(external.missingProvider)
		end

		return active_provider.doTaskDeferred(resume, ...)
	end,
	doTaskDelayed = function<A...>(
		sec: number,
		resume: (A...) -> () | thread,
		...: A...
	): thread?
		if not active_provider then
			logError(external.missingProvider)
		end

		return active_provider.doTaskDelayed(sec, resume, ...)
	end,
	cancelTask = function(task: thread): boolean
		if not active_provider then
			logError(external.missingProvider)
		end

		return active_provider.cancelTask(task)
	end,

	logError = logError,
	logErrorNonFatal = function(message: string, err: logging.Error?, ...: any?)
		local formatted_message = formatError(message, err, ...)

		if active_provider then
			active_provider.logErrorNonFatal(formatted_message)
		else
			print(formatted_message)
		end
	end,
	logWarn = function(message: string, ...: any?)
		local formatted_message = formatError(message, debug.traceback(nil, 2), ...)

		if active_provider then
			active_provider.logWarn(formatted_message)
		else
			print(formatted_message)
		end
	end,
}

return External
