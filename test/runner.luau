local butler = require("./butler")
local units = require("./spec")

local fmt = butler.results_formatter({
	disable_emoji = true,
})

local results = butler.run_units(units)

print(fmt(results))
