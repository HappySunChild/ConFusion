local memory = require("./types")

local External = require("../core-external/External")
local ExternalDebug = require("../core-external/ExternalDebug")

local cast_to_graph = require("../core-graph/cast_to_graph")

local function is_scope(value: unknown): boolean
	return typeof(value) == "table" and value[1] ~= nil
end

local ACTIVE_TASKS = {}

local function destroy(cleanup_task: memory.CleanupTask?)
	if cleanup_task == nil then
		return
	end

	if ACTIVE_TASKS[cleanup_task] ~= nil then
		External.log_error(memory.destroyed_twice)
	end

	ACTIVE_TASKS[cleanup_task] = true

	local task_type = typeof(cleanup_task)

	-- TODO: https://github.com/HappySunChild/ConFusion/issues/50

	if task_type == "Instance" then
		cleanup_task = cleanup_task :: Instance

		cleanup_task:Destroy()
	elseif task_type == "RBXScriptConnection" then
		cleanup_task = cleanup_task :: RBXScriptConnection

		cleanup_task:Disconnect()
	elseif task_type == "function" then
		cleanup_task = cleanup_task :: () -> ()

		cleanup_task()
	elseif is_scope(cleanup_task) then
		cleanup_task = cleanup_task :: { memory.CleanupTask }

		for i = #cleanup_task, 1, -1 do
			destroy(cleanup_task[i])

			cleanup_task[i] = nil
		end

		ExternalDebug.untrack_scope(cleanup_task)
	elseif cast_to_graph(cleanup_task) ~= nil then
		cleanup_task:destroy()
		-- this is kind of annoying.
		-- else
		-- 	External.log_warn(memory.unknown_cleanup_task, name_of(cleanup_task, "unknown"))
	end

	ACTIVE_TASKS[cleanup_task] = nil
end

return destroy :: memory.Destroy
