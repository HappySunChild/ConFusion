local instances = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"
local SpecialKey = require "./SpecialKey"

local KEY_CACHE = {}

local function OnChange(property: string): instances.SpecialKey<"OnChange">
	local key = KEY_CACHE[property]

	if key == nil then
		key = SpecialKey "observer" {
			name = `OnChange_{property}`,
			apply = function(
				scope: memory.Scope,
				apply_to: Instance,
				callback: (any) -> ()
			)
				local ok, event =
					pcall(apply_to.GetPropertyChangedSignal, apply_to, property)

				if not ok then
					External.logError(
						instances.cannotConnectChange,
						nil,
						apply_to.ClassName,
						property
					)
				end

				table.insert(
					scope,
					event:Connect(function()
						callback(apply_to[property])
					end)
				)
			end,
		}

		KEY_CACHE[property] = key
	end

	return key
end

return OnChange
