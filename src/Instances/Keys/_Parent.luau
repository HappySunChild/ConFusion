local Types = require "../../Types"

local observe = require "../../Graph/observe"

local castToState = require "../../State/castToState"
local peek = require "../../State/peek"

local SpecialKey = require "./SpecialKey"

local function setParent(instance: Instance, parent: Instance?)
	local success, err = pcall(function()
		instance.Parent = parent
	end)

	if not success then
		warn(err)
	end
end

local Parent = SpecialKey "Parent" {
	stage = "ancestor",
	apply = function(
		scope: Types.Scope,
		applyTo: Instance,
		parent: Types.UsedAs<Instance?>
	)
		if castToState(parent) then
			observe(scope, parent, function()
				setParent(applyTo, peek(parent))
			end)
		end

		setParent(applyTo, peek(parent))
	end,
} :: Types.SpecialKey<"Parent">

return Parent
