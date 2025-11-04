local calc = require "../core-calc/types"
local iter = require "../iter/types"
local memory = require "../core-memory/types"

export type ComputedPair<IK, IV, OK, OV> = {
	scope: memory.Scope?,
	input_key: IK,
	input_value: IV,
	roam_keys: boolean,
	roam_values: boolean,

	invalidateInputKey: (ComputedPair<IK, IV, OK, OV>) -> (),
	invalidateInputValue: (ComputedPair<IK, IV, OK, OV>) -> (),
	useOutputPair: (ComputedPair<IK, IV, OK, OV>, calc.Use) -> (OK?, OV?),
}

export type ForPairsProcessor<S, IK, IV, OK, OV> = (
	use: calc.Use,
	scope: memory.Scope<S>,
	input_key: IK,
	input_value: IV
) -> (OK, OV)
export type ForPairsConstructor = <S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: ForPairsProcessor<S, IK, IV, OK, OV>
) -> iter.Iter<OK, OV> | { [OK]: OV }

export type ForKeysProcessor<S, IK, OK> = (
	use: calc.Use,
	scope: memory.Scope<S>,
	input_key: IK
) -> OK
export type ForKeysConstructor = <S, IK, IV, OK>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: ForKeysProcessor<S, IK, OK>
) -> iter.Iter<OK, IV> | { [OK]: IV }

export type ForValuesProcessor<S, IV, OV> = (
	use: calc.Use,
	scope: memory.Scope<S>,
	input_value: IV
) -> OV
export type ForValuesConstructor = <S, IK, IV, OV>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: ForValuesProcessor<S, IV, OV>
) -> iter.Iter<IK, OV> | { [IK]: OV }

return {
	for_key_collision = "The key '%*' was returned multiple times simultaneously, which is not allowed in `For` objects.\nInput:\n\tKey: %*\n\tValue: %*\n\nOutput:\n\tKey: %*\n\tValue: %*",
}
