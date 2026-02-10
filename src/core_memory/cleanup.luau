local memory = require("./types")

local External = require("../core_external/External")
local ExternalDebug = require("../core_external/ExternalDebug")

local ALREADY_DESTROYING: { [memory.Chore]: true } = {}

local function cleanup(chore: memory.Chore?)
	if chore == nil then
		return
	end

	if ALREADY_DESTROYING[chore] ~= nil then
		External.log_error(memory.destroyed_twice)
	end

	ALREADY_DESTROYING[chore] = true

	if typeof(chore) == "Instance" then -- Roblox Instances
		chore:Destroy()
	elseif typeof(chore) == "RBXScriptConnection" then -- Roblox Connections
		chore = chore :: RBXScriptConnection

		chore:Disconnect()
	elseif typeof(chore) == "function" then -- callback functions
		chore = chore :: () -> ()

		chore()
	elseif typeof(chore) == "table" then
		if chore[1] ~= nil then -- scope/array of chores
			chore = chore :: { memory.Chore }

			for i = #chore, 1, -1 do
				cleanup(chore[i])

				chore[i] = nil
			end

			ExternalDebug.untrack_scope(chore)
		elseif typeof(chore.destroy) == "function" then -- :destroy method
			chore:destroy()
		elseif typeof(chore.Destroy) == "function" then -- :Destroy method
			chore:Destroy()
		elseif typeof(chore.disconnect) == "function" then -- :disconnect method
			chore:disconnect()
		elseif typeof(chore.Disconnect) == "function" then -- :Disconnect method
			chore:Disconnect()
		end
	end

	ALREADY_DESTROYING[chore] = nil
end

return cleanup
