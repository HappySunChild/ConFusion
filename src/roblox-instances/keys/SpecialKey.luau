local instances = require "../types"
local memory = require "../../core-memory/types"

type SpecialKeyProperties = {
	name: string?,
	apply: (scope: memory.Scope, apply_to: Instance, value: unknown) -> (),
}

local CLASS = table.freeze {
	type = "SpecialKey",
}
local METATABLE = table.freeze { __index = CLASS }

local function SpecialKey(
	stage: instances.SpecialKeyStage,
	kind: string,
	apply_callback: (
		scope: memory.Scope,
		apply_to: Instance,
		value: unknown
	) -> ()
)
	return table.freeze(setmetatable({
		stage = stage,
		kind = kind,

		apply = apply_callback,
	}, METATABLE))
end

return SpecialKey
