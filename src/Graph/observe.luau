local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local Observer = require(package.Graph.Observer)

local function observe(target: Types.GraphObject, callback: () -> (), immediate: boolean?)
	local newObserver = Observer(target.scope, target)

	if immediate then
		External.doTaskImmediate(callback)
	end

	return newObserver:onUpdate(callback)
end

return observe
