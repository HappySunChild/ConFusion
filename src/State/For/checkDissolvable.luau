local Types = require "../../Types"

local deriveScope = require "../../Memory/deriveScope"
local doCleanup = require "../../Memory/doCleanup"

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

	local innerScope = deriveScope(scope)
	local output = {}

	for key, value in input do
		local ok, newKey, newValue =
			pcall(processor, dissolvingUse, innerScope, key, value)

		if not ok then
			doCleanup(innerScope)

			return false
		end

		newKey = newKey or key
		newValue = newValue or value

		output[newKey] = newValue
	end

	table.insert(scope, innerScope)

	print("dissolved for", output)

	return true, output
end

return checkDissolvable
