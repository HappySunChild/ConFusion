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

local function sort_keys(a: instances.SpecialKey, b: instances.SpecialKey)
	local a_index = table.find(STAGE_ORDER, a.stage)
	local b_index = table.find(STAGE_ORDER, b.stage)

	if not a_index then
		External.log_warn(
			if a.stage == nil
				then instances.missing_specialkey_stage
				else instances.invalid_specialkey_stage,
			a.type,
			a.stage
		)

		return true
	elseif not b_index then
		External.log_warn(
			if b.stage == nil
				then instances.missing_specialkey_stage
				else instances.invalid_specialkey_stage,
			b.type,
			b.stage
		)

		return false
	end

	return a_index < b_index
end

return sort_keys
