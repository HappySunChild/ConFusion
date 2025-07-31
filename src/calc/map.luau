local calc = require "./types"

local Computed = require "./Computed"
local castToState = require "./castToState"

-- TODO: maybe add support for mapping multiple values?

local function map<V, O>(value: calc.UsedAs<V>, callback: (V) -> O?): calc.Computed<O> | O
	if not castToState(value) then
		return callback(value)
	end

	return Computed(value.scope, function(use)
		return callback(use(value))
	end)
end

return map
