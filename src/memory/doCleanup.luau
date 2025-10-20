local memory = require "./types"

local External = require "../external/External"
local ExternalDebug = require "../external/ExternalDebug"

local active = {}

local function doCleanup(cleanup_task: memory.CleanupTask)
	if active[cleanup_task] then
		External.logError(memory.destroyedTwice)
	end

	active[cleanup_task] = true

	local task_type = typeof(cleanup_task)

	if task_type == "Instance" then
		cleanup_task:Destroy()
	elseif task_type == "RBXScriptConnection" then
		cleanup_task:Disconnect()
	elseif task_type == "function" then
		cleanup_task()
	elseif task_type == "table" then
		cleanup_task = cleanup_task :: { memory.CleanupTask }

		if cleanup_task[1] ~= nil then
			for i = #cleanup_task, 1, -1 do
				doCleanup(cleanup_task[i])

				cleanup_task[i] = nil
			end

			ExternalDebug.untrackScope(cleanup_task)
		end
	end

	active[cleanup_task] = nil
end

return doCleanup
