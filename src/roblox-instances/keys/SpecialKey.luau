local instances = require "../types"
local memory = require "../../core-memory/types"

type SpecialKeyProperties = {
	name: string?,
	apply: (scope: memory.Scope, apply_to: Instance, value: unknown) -> (),
}

local function SpecialKey(stage: instances.SpecialKeyStage)
	return function(properties: SpecialKeyProperties): instances.SpecialKey
		return table.freeze {
			stage = stage,
			kind = "key",

			type = properties.name or "SpecialKey",
			apply = properties.apply,
		}
	end
end

return SpecialKey
