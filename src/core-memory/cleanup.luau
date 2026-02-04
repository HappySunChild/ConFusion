local memory = require("./types")

local External = require("../core-external/External")
local ExternalDebug = require("../core-external/ExternalDebug")

local cast_to_graph = require("../core-graph/cast_to_graph")

local function is_scope(value: unknown): boolean
	return typeof(value) == "table" and value[1] ~= nil
end

local ACTIVE_TASKS = {}

local function cleanup(task: memory.CleanupTask?)
	if task == nil then
		return
	end

	if ACTIVE_TASKS[task] ~= nil then
		External.log_error(memory.destroyed_twice)
	end

	ACTIVE_TASKS[task] = true

	local task_type = typeof(task)

	-- TODO: https://github.com/HappySunChild/ConFusion/issues/50

	if task_type == "Instance" then
		task = task :: Instance

		task:Destroy()
	elseif task_type == "RBXScriptConnection" then
		task = task :: RBXScriptConnection

		task:Disconnect()
	elseif task_type == "function" then
		task = task :: () -> ()

		task()
	elseif is_scope(task) then
		task = task :: { memory.CleanupTask }

		for i = #task, 1, -1 do
			cleanup(task[i])

			task[i] = nil
		end

		ExternalDebug.untrack_scope(task)
	elseif cast_to_graph(task) ~= nil then
		task:destroy()
		-- this is kind of annoying.
		-- else
		-- 	External.log_warn(memory.unknown_cleanup_task, name_of(cleanup_task, "unknown"))
	end

	ACTIVE_TASKS[task] = nil
end

return cleanup
