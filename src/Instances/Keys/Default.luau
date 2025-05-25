local SpecialKey = require "./SpecialKey"

-- resets properties to Roblox's defaults, I couldn't think of a way to improve this without just removing `defaultProperties`
local Default = SpecialKey "Default" {
	stage = "self",
	apply = function(_, applyTo: Instance, props: { string })
		for _, property in props do
			applyTo:ResetPropertyToDefault(property)
		end
	end,
}

return Default
