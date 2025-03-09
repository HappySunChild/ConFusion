local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local function observe(target: Types.GraphObject, callback: () -> (), immediate: boolean?)
	local observers = target._observers

	if not observers then
		observers = {}

		target._observers = observers
	end

	observers[callback] = true

	if immediate then
		External.doTaskImmediate(callback)
	end

	return function()
		observers[callback] = nil
	end
end

return observe
