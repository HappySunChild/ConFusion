local SpecialKey = require "../../roblox-instances/keys/SpecialKey"

return SpecialKey(
	"self",
	"StyleDerives",
	function(_, apply_to: StyleSheet, derives: { StyleSheet })
		apply_to:SetDerives(derives)
	end
)
