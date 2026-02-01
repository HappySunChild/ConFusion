local instances = require("../types")
local memory = require("../../core-memory/types")

local External = require("../../core-external/External")
local SpecialKey = require("../SpecialKey")

local function get_property(instance: Instance, key: string)
	return instance[key]
end

local KEY_CACHE = {}

local function OnEvent(event_name: string): instances.SpecialKey<"OnEvent">
	local key = KEY_CACHE[event_name]

	if key == nil then
		key = SpecialKey(
			"observer",
			"OnEvent",
			function(scope: memory.Scope, apply_to: Instance, callback: (...unknown) -> ())
				local ok, event = pcall(get_property, apply_to, event_name)

				if not ok or typeof(event) ~= "RBXScriptSignal" then
					External.log_error(
						instances.cannot_connect_event,
						nil,
						apply_to.ClassName,
						event_name
					)
				end

				table.insert(scope, event:Connect(callback))
			end
		)

		KEY_CACHE[event_name] = key
	end

	return key
end

return OnEvent
