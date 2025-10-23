local instances = require "../types"

local External = require "../../core-external/External"

local STAGE_ORDER = table.freeze {
	"self",
	"descendants",
	"properties",
	"ancestor",
	"observer",
	"last",
}

local function sortKeys(a: instances.SpecialKey, b: instances.SpecialKey)
	local a_index = table.find(STAGE_ORDER, a.stage)
	local b_index = table.find(STAGE_ORDER, b.stage)

	if not a_index then
		External.logWarn(
			if a.stage == nil
				then instances.missingSpecialKeyStage
				else instances.invalidSpecialKeyStage,
			a.type,
			a.stage
		)

		return true
	elseif not b_index then
		External.logWarn(
			if b.stage == nil
				then instances.missingSpecialKeyStage
				else instances.invalidSpecialKeyStage,
			b.type,
			b.stage
		)

		return false
	end

	return a_index < b_index
end

return sortKeys
