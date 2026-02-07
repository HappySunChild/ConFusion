local external = require("../core-external/types")

local External = require("../core-external/External")
local perform_update_step = External.perform_update_step

local task = require("@lune/task")

local SCHEDULER_RATE_HZ = 60

local scheduler_thread: thread? = nil

local function schedule_runner()
	while true do
		perform_update_step()

		task.wait(1 / SCHEDULER_RATE_HZ)
	end
end

local LuneProvider = table.freeze({
	do_task_immediate = task.spawn,
	do_task_deferred = task.defer,
	do_task_delayed = task.delay,
	cancel_task = function(thread: thread)
		local success = pcall(task.cancel, thread)

		return success
	end,

	start_scheduler = function()
		scheduler_thread = task.spawn(schedule_runner)
	end,
	stop_scheduler = function()
		if scheduler_thread ~= nil then
			task.cancel(scheduler_thread)
			scheduler_thread = nil
		end
	end,

	log_error_nonfatal = function(message: string)
		task.spawn(error, message, 0)
	end,
	log_warn = warn,
})

return LuneProvider :: external.ExternalProvider
