local calc = require "../../calc/types"
local instances = require "../types"
local memory = require "../../memory/types"

local Observer = require "../../graph/Observer"

local castToState = require "../../calc/castToState"

local peek = require "../../use/peek"

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
		scope: memory.Scope,
		applyTo: Instance,
		parent: calc.UsedAs<Instance?>
	)
		if castToState(parent) then
			Observer(scope, parent):onBind(function()
				setParent(applyTo, peek(parent))
			end)
		end

		setParent(applyTo, peek(parent))
	end,
} :: instances.SpecialKey<"Parent">

return Parent
