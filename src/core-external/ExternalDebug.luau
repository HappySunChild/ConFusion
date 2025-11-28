local external = require "./types"
local memory = require "../core-memory/types"

local name_of = require "../core-logging/name_of"

local active_debugger: external.ExternalDebugger? = nil

return table.freeze {
	getName = name_of,
	setDebugger = function(new_debugger: external.ExternalDebugger?)
		local old_debugger = active_debugger

		if old_debugger ~= nil then
			old_debugger.stop_debugging()
		end

		if new_debugger then
			new_debugger.start_debugging()
		end

		active_debugger = new_debugger

		return old_debugger
	end,
	trackScope = function(scope: memory.Scope)
		if active_debugger == nil then
			return
		end

		active_debugger.track_scope(scope)
	end,
	untrackScope = function(scope: memory.Scope)
		if active_debugger == nil then
			return
		end

		active_debugger.untrack_scope(scope)
	end,
}
