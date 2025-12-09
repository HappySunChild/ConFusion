local match = require "./types"

local CLASS = table.freeze { type = "WrappedPattern" }
local METATABLE = table.freeze { __index = CLASS }

local function wrapPriority(pattern: any, priority: number): match.WrappedPattern
	return setmetatable({
		pattern = pattern,
		priority = priority,
	}, METATABLE)
end

return wrapPriority
