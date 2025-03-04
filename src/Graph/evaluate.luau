local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local notify = require(package.Graph.notify)

local function evaluate(target: Types.GraphObject, forceComputation: boolean?)
	if target.validity == "busy" then
		return External.logError("infiniteLoop", nil, target.type, target.kind)
	end

	local firstEvaluation = target._lastChange == nil
	local isInvalid = target.validity == "invalid"

	if firstEvaluation or isInvalid or forceComputation then
		local shouldCompute = firstEvaluation or forceComputation

		-- check if computation is actually needed
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

			target.validity = "busy"

			targetMeaningfullyChanged = target:_evaluate() or firstEvaluation
		end

		target.validity = "valid"

		if targetMeaningfullyChanged then
			notify(target, target._internalValue)

			target._lastChange = os.clock()
		end

		return targetMeaningfullyChanged
	end

	return false
end

return evaluate
