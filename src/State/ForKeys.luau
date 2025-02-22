local package = script.Parent.Parent

local Types = require(package.Types)

local For = require(package.State.For)

type KeysProcessor<IK, OK> = (Types.Use, IK) -> OK

local function wrapProcessor<IK, IV, OV>(processor: KeysProcessor<IV, OV>)
	return function(use: Types.Use, inputKey: IK, inputValue: IV)
		local newKey = processor(use, inputKey)

		return newKey, inputValue
	end
end

local function ForValues<IK, IV, OK>(
	scope: Types.Scope,
	input: Types.UsedAs<{ [IK]: IV }>,
	processor: KeysProcessor<IK, OK>
): Types.For<IK, IV, OK, IV>
	return For(scope, input, wrapProcessor(processor))
end

return ForValues
