local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

--[[
	local castToState = require(package.State.castToState)

	local evaluate = require(package.Graph.evaluate)

	local function observe<V>(
		target: Types.StateObject<V>,
		callback: () -> (),
		immediate: boolean?
		)
		if not castToState(target) then
			return External.logError("invalidObserveType", nil, typeof(target))
		end
		
	evaluate(target, false)
	
	local observers = target._observers

	if observers == nil then
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
]]

local Observer = require(package.Graph.Observer)

local function observe(target: Types.GraphObject, callback: () -> (), immediate: boolean?)
	local newObserver = Observer(target.scope, target)

	if immediate then
		External.doTaskImmediate(callback)
	end

	return newObserver:onUpdate(callback)
end

return observe
