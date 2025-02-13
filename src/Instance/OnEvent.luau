local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local eventCache = {}

local function OnEvent(eventName: string): Types.SpecialKey
	local key = eventCache[eventName]

	if not key then
		key = table.freeze {
			[Symbols.Kind] = Kinds.Key,
			[Symbols.Type] = Types.Event,

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

		eventCache[eventName] = key
	end

	return key
end

return OnEvent
