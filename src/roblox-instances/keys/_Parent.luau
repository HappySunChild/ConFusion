local calc = require "../../core-calc/types"
local instances = require "../types"
local memory = require "../../core-memory/types"

local observe = require "../../core-graph/observe"

local castToState = require "../../core-calc/castToState"

local peek = require "../../core-use/peek"

local SpecialKey = require "./SpecialKey"

local function setParent(instance: Instance, parent: Instance?)
	local success, err = pcall(function()
		instance.Parent = parent
	end)

	if not success then
		warn(err)
	end
end

local Parent = SpecialKey "ancestor" {
	name = "Parent",
	apply = function(
		scope: memory.Scope,
		apply_to: Instance,
		parent: calc.UsedAs<Instance?>
	)
		if castToState(parent) then
			observe(scope, parent, function()
				setParent(apply_to, peek(parent))
			end)
		end

		setParent(apply_to, peek(parent))
	end,
} :: instances.SpecialKey<"Parent">

return Parent
