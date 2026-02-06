local calc = require("../../core-calc/types")
local instances = require("../types")
local memory = require("../../core-memory/types")

local SpecialKey = require("../SpecialKey")
local observe_immediate = require("../../core-graph/observe_immediate")
local peek = require("../../core-use/peek")

local KEY_CACHE = {}

local function Tag(tag: string): instances.SpecialKey<"Tag">
	local key = KEY_CACHE[tag]

	if key == nil then
		key = SpecialKey(
			"self",
			"Tag",
			function(scope: memory.Scope, apply_to: Instance, enabled: calc.UsedAs<boolean>)
				observe_immediate(scope, enabled, function()
					local value = peek(enabled)

					if value == true then
						apply_to:AddTag(tag)
					elseif apply_to:HasTag(tag) then
						apply_to:RemoveTag(tag)
					end
				end)
			end
		)

		KEY_CACHE[tag] = key
	end

	return key
end

return Tag
