local calc = require "../../core-calc/types"
local instances = require "../types"
local memory = require "../../core-memory/types"

local observe = require "../../core-graph/observe"

local peek = require "../../core-use/peek"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function Tag(tag: string): instances.SpecialKey<"Tag">
	local key = keyCache[tag]

	if not key then
		key = SpecialKey "self" {
			name = `Tag_{tag}`,
			apply = function(
				scope: memory.Scope,
				apply_to: Instance,
				enabled: calc.UsedAs<boolean>
			)
				observe(scope, enabled, function()
					local value = peek(enabled)

					if value == true then
						apply_to:AddTag(tag)
					elseif apply_to:HasTag(tag) then
						apply_to:RemoveTag(tag)
					end
				end, true)
			end,
		}

		keyCache[tag] = key
	end

	return key
end

return Tag
