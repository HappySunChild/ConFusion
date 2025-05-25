local Types = require "../../Types"

local castToState = require "../../State/castToState"
local peek = require "../../State/peek"

local observe = require "../../Graph/observe"

local SpecialKey = require "./SpecialKey"

-- this SpecialKey is kind of redundant, because you can just add a StyleLink as a child of a ScreenGui (or whatever)
-- and it'd work the same. ugh why is coming up with cool and useful things so hard
local StyleLink = SpecialKey "StyleLink" {
	stage = "descendants",
	apply = function(
		scope: Types.Scope,
		applyTo: Instance,
		styleSheet: Types.UsedAs<StyleSheet?>
	)
		local link = Instance.new "StyleLink"
		link.Parent = applyTo
		link.StyleSheet = peek(styleSheet)

		if castToState(styleSheet) then
			table.insert(
				scope,
				observe(styleSheet, function()
					link.StyleSheet = peek(styleSheet)
				end)
			)
		end

		table.insert(scope, link)
	end,
}

return StyleLink
