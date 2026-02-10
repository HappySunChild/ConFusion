local units = require("./spec")

local butler = require("@butler/butler")
local butler_chrono = require("@butler/hooks/butler_chrono")
local butler_pretty = require("@butler/hooks/butler_pretty")

local configured = butler({
	hooks = {
		butler_chrono,
		butler_pretty({
			disable_emoji = true,
			hooks = { butler_chrono },
		}),
	},
})

local collected = {}

type UnitsContainer = { (butler.Configured) -> butler.UnitRunner | UnitsContainer }

local function collect(units: UnitsContainer)
	for _, unit in units do
		if typeof(unit) == "function" then
			table.insert(collected, unit(configured))
		elseif typeof(unit) == "table" then
			collect(unit)
		end
	end
end

collect(units)

configured.run_units(collected)
