local graph = require "./types"

local External = require "../core-external/External"

local xtypeof = require "../xtypeof"

local castToGraph = require "./castToGraph"

local function evaluate(target: graph.GraphObject, forceComputation: boolean?)
	if not castToGraph(target) then
		return External.logErrorNonFatal(graph.invalidEvaluateType, nil, xtypeof(target))
	end

	if target.validity == "busy" then
		return External.logError(graph.infiniteLoop)
	end

	local first_evaluation = target._lastChange == nil or target._lastCompute == nil
	local is_invalid = target.validity == "invalid"

	if first_evaluation or is_invalid or forceComputation then
		local needs_computation = first_evaluation or forceComputation

		-- check if computation is actually needed
		if not needs_computation then
			for dependency in target._using do
				evaluate(dependency, false)

				if dependency._lastChange > target._lastCompute then
					needs_computation = true

					break
				end
			end
		end

		local meaningfully_changed = false

		if needs_computation then
			-- remove dependencies
			for dependency in target._using do
				dependency._users[target] = nil
				target._using[dependency] = nil
			end

			target.validity = "busy"

			meaningfully_changed = target:_evaluate() or first_evaluation

			target._lastCompute = os.clock()
		end

		if meaningfully_changed then
			target._lastChange = os.clock()
		end

		target.validity = "valid"

		return meaningfully_changed
	end

	return false
end

return evaluate
