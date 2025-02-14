local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local keyCache = {}

local function OnEvent(eventName: string): Types.SpecialKey
	local key = keyCache[eventName]

	if not key then
		key = table.freeze {
			[Symbols.Kind] = 'key',
			[Symbols.Type] = 'onEvent',

			apply = function(scope: Types.Scope, instance: Instance, callback)
				local success, eventSignal = pcall(function()
					return instance[eventName]
				end)

				if not success then
					return error(`'{eventName}' is not a valid event of {instance.ClassName}!`)
				end

				table.insert(scope, eventSignal:Connect(callback))

				return
			end,
		}

		keyCache[eventName] = key
	end

	return key
end

return OnEvent
