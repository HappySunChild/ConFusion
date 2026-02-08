local results_formatter = require("@self/fmt/results_formatter")

local butler = table.freeze({
	-- UNIT HANDLING
	unit = require("@self/unit/unit"),
	run_units = require("@self/unit/run_units"),

	-- TEST IMPL
	test = require("@self/test/test"),
	expect = require("@self/test/expect"),

	-- FORMATTING
	results_formatter = results_formatter,
	default_fmt = results_formatter({}),
})

return butler
