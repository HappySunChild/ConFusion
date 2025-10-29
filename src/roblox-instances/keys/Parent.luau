local calc = require "../../core-calc/types"
local instances = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"
local SpecialKey = require "./SpecialKey"
local observe = require "../../core-graph/observe"
local peek = require "../../core-use/peek"

local function setParent(instance: Instance, parent: Instance?)
	local success, err = pcall(function()
		instance.Parent = parent
	end)

	if not success then
		External.logWarn(err)
	end
end

return SpecialKey "ancestor" {
	name = "Parent",
	apply = function(
		scope: memory.Scope,
		apply_to: Instance,
		parent: calc.UsedAs<Instance?>
	)
		observe(scope, parent, function()
			setParent(apply_to, peek(parent))
		end, true)
	end,
} :: instances.SpecialKey<"Parent">
