local external = require "./types"
local memory = require "../memory/types"

local nameOf = require "../logging/nameOf"

local active_debugger: external.ExternalDebugger? = nil

return table.freeze {
	getName = nameOf,
	setDebugger = function(new_debugger: external.ExternalDebugger?)
		local old_debugger = active_debugger

		if old_debugger ~= nil then
			old_debugger.stopDebugging()
		end

		if new_debugger then
			new_debugger.startDebugging()
		end

		active_debugger = new_debugger

		return old_debugger
	end,
	trackScope = function(scope: memory.Scope)
		if active_debugger == nil then
			return
		end

		active_debugger.trackScope(scope)
	end,
	untrackScope = function(scope: memory.Scope)
		if active_debugger == nil then
			return
		end

		active_debugger.untrackScope(scope)
	end,
}
