local memory = require "./types"

local External = require "../core-external/External"

local active = {}

local function doCleanup(action: memory.CleanupTask)
	if active[action] then
		External.logError(memory.destroyedTwice)
	end

	active[action] = true

	local task_type = typeof(action)

	if task_type == "Instance" then
		(action :: Instance):Destroy()
	elseif task_type == "RBXScriptConnection" then
		(action :: RBXScriptConnection):Disconnect()
	elseif task_type == "function" then
		(action :: () -> ())()
	elseif task_type == "table" then
		action = action :: { memory.CleanupTask }

		if action[1] ~= nil then
			for i = #action, 1, -1 do
				doCleanup(action[i])

				action[i] = nil
			end
		end
	end

	active[action] = nil
end

return doCleanup
