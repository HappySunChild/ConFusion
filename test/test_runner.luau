local butler = require("@butler/butler")
local butler_chrono = require("@butler/hooks/butler_chrono")
local butler_pretty = require("@butler/hooks/butler_pretty")

local External = require("@fusion/core_external/External")

local SpecProvider = require("./SpecProvider")
local units = require("./spec")

External.set_provider(SpecProvider)

local configured = butler({
	hooks = {
		butler_chrono,
		butler_pretty({
			disable_color = game ~= nil,
			disable_emoji = true,
			line_width = 100,
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
