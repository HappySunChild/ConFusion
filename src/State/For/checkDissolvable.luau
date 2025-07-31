local Types = require "../../Types"

local doCleanup = require "../../Memory/doCleanup"
local innerScope = require "../../Memory/innerScope"

local castToState = require "../castToState"
local dissolvingUse = require "../dissolvingUse"

local function checkDissolvable<S, IK, IV, OK, OV>(
	scope: Types.Scope<S>,
	input: Types.UsedAs<{ [IK]: IV }>,
	processor: (
		Types.Use,
		Types.Scope<S>,
		IK,
		IV
	) -> (OK?, OV?)
)
	if castToState(input) then
		return false
	end

	local dissolveScope = innerScope(scope)
	local output = {}

	for key, value in input do
		local ok, newKey, newValue =
			pcall(processor, dissolvingUse, dissolveScope, key, value)

		if not ok then
			doCleanup(dissolveScope)

			return false
		end

		newKey = newKey or key
		newValue = newValue or value

		output[newKey] = newValue
	end

	return true, output
end

return checkDissolvable
