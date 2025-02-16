local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local keyCache = {}

local function OnEvent(eventName: string): Types.SpecialKey
	local key = keyCache[eventName]

	if not key then
		key = table.freeze {
			kind = 'key',
			type = 'onEvent',

			apply = function(scope: Types.Scope, applyTo: Instance, callback)
				local success, eventSignal = pcall(function()
					return applyTo[eventName]
				end)

				if not success then
					return error(`'{eventName}' is not a valid event of {applyTo.ClassName}!`)
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
