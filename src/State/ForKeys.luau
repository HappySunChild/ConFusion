local package = script.Parent.Parent

local Types = require(package.Types)

local For = require(package.State.For)

type KeysProcessor<S, IK, OK> = (Types.Use, Types.Scope<S>, IK) -> OK

local function wrapProcessor<IK, IV, OV>(processor: KeysProcessor<IV, OV>)
	return function(use: Types.Use, scope: Types.Scope, inputKey: IK, inputValue: IV)
		local newKey = processor(use, scope, inputKey)

		return newKey, inputValue
	end
end

local function ForValues<S, IK, IV, OK>(
	scope: Types.Scope<S>,
	input: Types.UsedAs<{ [IK]: IV }>,
	processor: KeysProcessor<S, IK, OK>
): Types.For<IK, IV, OK, IV>
	return For(scope, input, wrapProcessor(processor))
end

return ForValues
