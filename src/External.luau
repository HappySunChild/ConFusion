--!strict
local log = require "./log/types"

export type ExternalProvider = {
	startScheduler: () -> (),
	stopScheduler: () -> (),

	logErrorNonFatal: (message: string) -> (),
	logWarn: (message: string) -> (),

	doTaskImmediate: (resume: (...unknown) -> (), ...unknown) -> thread?,
	doTaskDeferred: (resume: (...unknown) -> (), ...unknown) -> thread?,
	cancelTask: (task: thread) -> boolean,
}

local formatError = require "./log/formatError"

local boundCallbacks = {}
local activeProvider: ExternalProvider? = nil

local lastUpdate = os.clock()
local deltaTime = 0

local External = table.freeze {
	setProvider = function(newProvider: ExternalProvider?)
		local oldProvider = activeProvider

		if oldProvider ~= nil then
			oldProvider.stopScheduler()
		end

		activeProvider = newProvider

		if newProvider then
			newProvider.startScheduler()
		end

		return oldProvider
	end,
	bindToUpdate = function(callback: (now: number) -> ()): () -> ()
		local uniqueIdentifier = {}
		boundCallbacks[uniqueIdentifier] = callback

		return function()
			boundCallbacks[uniqueIdentifier] = nil
		end
	end,
	performUpdate = function(): ()
		local now = os.clock()

		deltaTime = now - lastUpdate
		lastUpdate = now

		for _, callback in boundCallbacks do
			callback(now)
		end
	end,

	getDeltaTime = function(): number
		return deltaTime
	end,
	getLastUpdate = function(): number
		return lastUpdate
	end,

	doTaskImmediate = function(resume: (...any?) -> (), ...: any?): thread?
		if not activeProvider then
			return nil
		end

		return activeProvider.doTaskImmediate(resume, ...)
	end,
	doTaskDeferred = function(resume: (...any?) -> (), ...: any?): thread?
		if not activeProvider then
			return nil
		end

		return activeProvider.doTaskDeferred(resume, ...)
	end,
	cancelTask = function(task: thread): boolean
		if not activeProvider then
			return false
		end

		return activeProvider.cancelTask(task)
	end,

	logError = function(
		messageId: formatError.MessageId,
		err: log.Error?,
		...: any?
	): never
		error(formatError(messageId, err, ...), 0)
	end,
	logErrorNonFatal = function(
		messageId: formatError.MessageId,
		err: log.Error?,
		...: any?
	)
		local message = formatError(messageId, err, ...)

		if activeProvider then
			activeProvider.logErrorNonFatal(message)
		else
			print(message)
		end
	end,
	logWarn = function(messageId: formatError.MessageId, err: log.Error, ...: any?)
		local message = formatError(messageId, err, ...)

		if activeProvider then
			activeProvider.logWarn(message)
		else
			print(message)
		end
	end,
}

return External
