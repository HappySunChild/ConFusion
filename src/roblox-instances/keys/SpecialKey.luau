local instances = require "../types"
local memory = require "../../core-memory/types"

type SpecialKeyProperties = {
	name: string?,
	apply: (scope: memory.Scope, applyTo: Instance, ...any) -> (),
}

local function SpecialKey(stage: instances.SpecialKeyStage)
	return function(props: SpecialKeyProperties): instances.SpecialKey
		local newKey = table.freeze {
			stage = stage,
			kind = "key",

			type = props.name or "SpecialKey",
			apply = props.apply,
		}

		return newKey
	end
end

return SpecialKey
