local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local function notify(target: Types.GraphObject, value: any)
	if target._observers then
		for callback in target._observers do
			External.doTaskImmediate(callback, value)
		end
	end
end

return notify
