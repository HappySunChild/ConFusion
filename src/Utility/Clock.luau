local package = script.Parent.Parent

local External = require(package.External)
local Value = require(package.State.Value)

local Clock = Value({}, os.clock())

External.bindToUpdate(function(now)
	Clock:set(now)
end)

return Clock
