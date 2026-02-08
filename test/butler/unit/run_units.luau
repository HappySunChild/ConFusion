local types = require("../types")

local function run_unit(units: { () -> types.UnitRunResult }): types.UnitsRunResult
	local total_duration = 0
	local total_tally = {
		fail = 0,
		pass = 0,
	}
	local individual_units = {}

	for _, unit in units do
		local result = unit()

		total_duration += result.duration
		total_tally.fail += result.tally.fail
		total_tally.pass += result.tally.pass

		table.insert(individual_units, result)
	end

	return {
		total_duration = total_duration,
		total_tally = total_tally,
		individual_units = individual_units,
	}
end

return run_unit
