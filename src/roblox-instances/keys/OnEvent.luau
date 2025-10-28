local instances = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"

local SpecialKey = require "./SpecialKey"

local function getProperty(instance: Instance, key: string)
	return instance[key]
end

local keyCache = {}

local function OnEvent(event_name: string): instances.SpecialKey<"OnEvent">
	local key = keyCache[event_name]

	if not key then
		key = SpecialKey "observer" {
			name = `OnEvent_{event_name}`,
			apply = function(
				scope: memory.Scope,
				apply_to: Instance,
				callback: (...unknown) -> ()
			)
				local ok, event = pcall(getProperty, apply_to, event_name)

				if not ok or typeof(event) ~= "RBXScriptSignal" then
					External.logError(
						instances.cannotConnectEvent,
						nil,
						apply_to.ClassName,
						event_name
					)
				end

				table.insert(scope, event:Connect(callback))
			end,
		}

		keyCache[event_name] = key
	end

	return key
end

return OnEvent
