local package = script.Parent.Parent

local External = require(package.External)
local Symbols = require(package.Symbols)

local function evaluate(target, forceComputation)
	if target[Symbols.Validity] == 'busy' then
		return External.logError 'infiniteLoop'
	end

	local firstEvaluation = target[Symbols.LastChange] == nil
	local isInvalid = target[Symbols.Validity] == 'invalid'

	if firstEvaluation or isInvalid or forceComputation then
		local needsComputation = firstEvaluation or forceComputation

		if not needsComputation then
			for dependency in target[Symbols.Using] do
				evaluate(dependency, false)

				if
					dependency[Symbols.LastChange] > target[Symbols.LastChange]
				then
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

		target[Symbols.Validity] = 'valid'

		if targetMeaningfullyChanged then
			if target[Symbols.Observers] then
				for callback in target[Symbols.Observers] do
					External.doTaskImmediate(
						callback,
						target[Symbols.InternalValue]
					)
				end
			end

			target[Symbols.LastChange] = os.clock()
		end

		return targetMeaningfullyChanged
	end

	return false
end

return evaluate
