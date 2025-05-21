local Types = require "../../Types"

local observe = require "../../Graph/observe"

local castToState = require "../../State/castToState"
local peek = require "../../State/peek"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function Tag(tag: string): Types.SpecialKey<"Tag">
	local key = keyCache[tag]

	if not key then
		key = SpecialKey "Tag" {
			stage = "self",
			apply = function(
				_: Types.Scope,
				instance: Instance,
				enabled: Types.UsedAs<boolean>
			)
				if castToState(enabled) then
					observe(enabled, function()
						local value = peek(enabled)

						if value == true then
							instance:AddTag(tag)
						elseif instance:HasTag(tag) then
							instance:RemoveTag(tag)
						end
					end)
				end

				if peek(enabled) then
					instance:AddTag(tag)
				end
			end,
		}

		keyCache[tag] = key
	end

	return key
end

return Tag
