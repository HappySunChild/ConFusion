local package = script.Parent.Parent

local Types = require(package.Types)

local For = require(package.State.For)

local function ForPairs<IK, IV, OK, OV>(
	scope: Types.Scope,
	input: Types.UsedAs<{ [IK]: IV }>,
	processor: (Types.Use, IK, IV) -> (OK, OV)
): Types.For<IK, IV, OK, OV>
	return For(scope, input, processor)
end

return ForPairs
