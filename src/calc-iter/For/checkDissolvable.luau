local calc = require "../../core-calc/types"
local iter = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"

local doCleanup = require "../../core-memory/doCleanup"
local innerScope = require "../../core-memory/innerScope"

local dissolvingUse = require "../../core-use/dissolvingUse"

local castToState = require "../../core-calc/castToState"

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
	if castToState(input) then
		return false, nil
	end

	local dissolvingScope = innerScope(scope)
	local output = {}

	for key, value in input do
		local ok, outputKey, outputValue =
			pcall(processor, dissolvingUse, dissolvingScope, key, value)

		if not ok then
			doCleanup(dissolvingScope)

			return false, nil
		end

		if outputKey == nil or outputValue == nil then
			continue
		elseif output[outputKey] ~= nil then
			External.logErrorNonFatal(iter.forKeyCollision, nil, tostring(outputKey))

			continue
		end

		output[outputKey] = outputValue
	end

	return true, output
end

return checkDissolvable
