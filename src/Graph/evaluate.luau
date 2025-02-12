local package = script.Parent.Parent

local Symbols = require(package.Symbols)

local function evaluate(target, forceComputation)
	if target[Symbols.Validity] == 'busy' then
		return error('Evaluate target is already being evaluated, possible infinite loop!', 2)
	end

	local firstEvaluation = target[Symbols.LastChange] == nil
	local isInvalid = target[Symbols.Validity] == 'invalid'

	if firstEvaluation or isInvalid or forceComputation then
		local needsComputation = firstEvaluation or forceComputation

		if not needsComputation then
			for dependency in target[Symbols.Using] do
				evaluate(dependency, false)

				if dependency[Symbols.LastChange] > target[Symbols.LastChange] then
					needsComputation = true

					break
				end
			end
		end

		local targetMeaningfullyChanged = false

		if needsComputation then
			for dependency in target[Symbols.Using] do
				dependency[Symbols.Users][target] = nil
				target[Symbols.Using][dependency] = nil
			end

			target[Symbols.Validity] = 'busy'
			targetMeaningfullyChanged = target:_evaluate() or firstEvaluation
		end

		if targetMeaningfullyChanged then
			target[Symbols.LastChange] = os.clock()
		end

		target[Symbols.Validity] = 'valid'

		return targetMeaningfullyChanged
	end

	return false
end

return evaluate
