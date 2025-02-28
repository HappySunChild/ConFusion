local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local function evaluate(target: Types.GraphObject, forceComputation: boolean?)
	if target._validity == "busy" then
		return External.logError "infiniteLoop"
	end

	local firstEvaluation = target._lastChange == nil
	local isInvalid = target._validity == "invalid"

	if firstEvaluation or isInvalid or forceComputation then
		local shouldCompute = firstEvaluation or forceComputation

		if not shouldCompute then
			for dependency in target._using do
				evaluate(dependency, false)

				if dependency._lastChange > target._lastChange then
					shouldCompute = true

					break
				end
			end
		end

		local targetMeaningfullyChanged = false

		if shouldCompute then
			-- remove dependencies
			
			for dependency in target._using do
				dependency._users[target] = nil
				target._using[dependency] = nil
			end

			target._validity = "busy"

			targetMeaningfullyChanged = target:_evaluate() or firstEvaluation
		end

		target._validity = "valid"

		if targetMeaningfullyChanged then
			if target._observers then
				for callback in target._observers do
					External.doTaskImmediate(callback, target._internalValue)
				end
			end

			target._lastChange = os.clock()
		end

		return targetMeaningfullyChanged
	end

	return false
end

return evaluate
