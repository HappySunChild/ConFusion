local calc = require "../../core-calc/types"
local iter = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"
local castToState = require "../../core-calc/castToState"
local dissolvingUse = require "../../core-use/dissolvingUse"
local doCleanup = require "../../core-memory/doCleanup"
local innerScope = require "../../core-memory/innerScope"

local function checkDissolvable<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	input: calc.UsedAs<{ [IK]: IV }>,
	processor: (
		calc.Use,
		memory.Scope<S>,
		IK,
		IV
	) -> (OK?, OV?)
): (boolean, { [OK]: OV }?)
	if castToState(input) ~= nil then
		return false, nil
	end

	local dissolving_scope = innerScope(scope)
	local output = {}

	for key, value in input do
		local ok, output_key, output_value =
			pcall(processor, dissolvingUse, dissolving_scope, key, value)

		if not ok then
			doCleanup(dissolving_scope)

			return false, nil
		end

		if output_key == nil or output_value == nil then
			continue
		elseif output[output_key] ~= nil then
			External.logErrorNonFatal(iter.for_key_collision, nil, tostring(output_key))

			continue
		end

		output[output_key] = output_value
	end

	return true, output
end

return checkDissolvable
