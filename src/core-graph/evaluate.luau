local graph = require "./types"

local External = require "../core-external/External"
local castToGraph = require "./castToGraph"
local xtypeof = require "../xtypeof"

local function evaluate(target: graph.GraphObject, force_computation: boolean?): boolean
	if castToGraph(target) == nil then
		External.logErrorNonFatal(graph.invalid_evaluate_type, nil, xtypeof(target))

		return
	end

	if target.validity == "busy" then
		External.logError(graph.infinite_loop)
	end

	local first_evaluation = target._last_change == nil or target._last_compute == nil
	local is_invalid = target.validity == "invalid"

	if not (first_evaluation or is_invalid or force_computation) then
		return false
	end

	local needs_computation = first_evaluation or force_computation

	-- check if computation is actually needed
	if not needs_computation then
		for dependency in target._using do
			evaluate(dependency, false)

			if dependency._last_change > target._last_compute then
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

		target._last_compute = os.clock()
	end

	if meaningfully_changed then
		target._last_change = os.clock()
	end

	target.validity = "valid"

	return meaningfully_changed
end

return evaluate
