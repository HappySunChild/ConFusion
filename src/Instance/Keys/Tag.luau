local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local Observer = require(package.Graph.Observer)
local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local keyCache = {}

local function Tag(tag: string): Types.SpecialKey
	local key = keyCache[tag]

	if not key then
		key = table.freeze {
			kind = 'key',
			type = 'tag',

			apply = function(scope: Types.Scope, instance: Instance, enabled: Types.UsedAs<boolean>)
				if castToState(enabled) then
					Observer(scope, enabled):onChange(function(new)
						if new == true then
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
