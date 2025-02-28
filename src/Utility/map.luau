local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local Computed = require(package.State.Computed)
local castToState = require(package.State.castToState)

local function map<V>(value: Types.StateObject<V>, callback: (V) -> any?): Types.Computed<V>
	if not castToState(value) then
		External.logError("invalidMapType", nil, typeof(value))
	end

	return Computed(value.scope, function(use)
		return callback(use(value))
	end)
end

return map
