local instances = require "../types"
local memory = require "../../core-memory/types"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function AttributeChange(attribute: string): instances.SpecialKey<"AttributeChange">
	local key = keyCache[attribute]

	if not key then
		key = SpecialKey "observer" {
			name = `AttributeChanged_{attribute}`,
			apply = function(
				scope: memory.Scope,
				apply_to: Instance,
				callback: (any) -> ()
			)
				local event = apply_to:GetAttributeChangedSignal(attribute)

				table.insert(
					scope,
					event:Connect(function()
						callback(apply_to:GetAttribute(attribute))
					end)
				)
			end,
		}

		keyCache[attribute] = key
	end

	return key
end

return AttributeChange
