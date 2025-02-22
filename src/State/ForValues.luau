local package = script.Parent.Parent

local Types = require(package.Types)

local For = require(package.State.For)

type ValuesProcessor<IV, OV> = (Types.Use, IV) -> OV

local function wrapProcessor<IK, IV, OV>(processor: ValuesProcessor<IV, OV>)
	return function(use: Types.Use, inputKey: IK, inputValue: IV)
		local newValue = processor(use, inputValue)

		return inputKey, newValue
	end
end

local function ForValues<IK, IV, OV>(
	scope: Types.Scope,
	input: Types.UsedAs<{ [IK]: IV }>,
	processor: ValuesProcessor<IV, OV>
): Types.For<IK, IV, IK, OV>
	return For(scope, input, wrapProcessor(processor))
end

return ForValues
