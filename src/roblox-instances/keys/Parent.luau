local calc = require "../../core-calc/types"
local instances = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"

local peek = require "../../core-use/peek"

local observeImmediate = require "../../core-graph/observeImmediate"

local SpecialKey = require "./SpecialKey"

local function setParent(instance: Instance, parent: Instance?)
	local success, err = pcall(function()
		instance.Parent = parent
	end)

	if not success then
		External.logWarn(err)
	end
end

return SpecialKey(
	"ancestor",
	"Parent",
	function(scope: memory.Scope, apply_to: Instance, parent: calc.UsedAs<Instance?>)
		observeImmediate(scope, parent, function()
			setParent(apply_to, peek(parent))
		end)
	end
) :: instances.SpecialKey<"Parent">
