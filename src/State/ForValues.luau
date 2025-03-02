local package = script.Parent.Parent

local Types = require(package.Types)

local For = require(package.State.For)

type ValuesProcessor<S, IV, OV> = (Types.Use, Types.Scope<S>, IV) -> OV

local function wrapProcessor<IK, IV, OV>(processor: ValuesProcessor<IV, OV>)
	return function(use: Types.Use, scope: Types.Scope, inputKey: IK, inputValue: IV)
		local newValue = processor(use, scope, inputValue)

		return inputKey, newValue
	end
end

local function ForValues<S, IK, IV, OV>(
	scope: Types.Scope<S>,
	input: Types.UsedAs<{ [IK]: IV }>,
	processor: ValuesProcessor<S, IV, OV>
): Types.For<IK, IV, IK, OV>
	return For(scope, input, wrapProcessor(processor))
end

return ForValues
