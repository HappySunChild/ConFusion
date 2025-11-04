local calc = require "../core-calc/types"
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

export type Disassembly<OK, OV> = calc.StateObject<{ [OK]: OV }> & {
	populate: (Disassembly<OK, OV>, calc.Use, output: { [OK]: OV }) -> (),
}

-- A state object which maps over keys and/or values in another table.
	timeliness: "lazy",
} & calc.StateObject<{ [K]: V }>

export type Range = {
	type: "Range",
	timeliness: "lazy",
} & calc.StateObject<{ number }>
export type RangeConstructor = (
	scope: memory.Scope,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	step: calc.UsedAs<number>?
) -> Range | { number }

export type ForRangeProcessor<S, T> = ForValuesProcessor<S, number, T>
export type ForRangeConstructor = <S, T>(
	scope: memory.Scope<S>,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	processor: ForRangeProcessor<S, T>,
	step: calc.UsedAs<number>?

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

export type ForKeysProcessor<S, IK, OK> = (
	use: calc.Use,
	scope: memory.Scope<S>,
	input_key: IK
) -> OK
export type ForKeysConstructor = <S, IK, IV, OK>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: ForKeysProcessor<S, IK, OK>

export type ForValuesProcessor<S, IV, OV> = (
	use: calc.Use,
	scope: memory.Scope<S>,
	input_value: IV
) -> OV
export type ForValuesConstructor = <S, IK, IV, OV>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: ForValuesProcessor<S, IV, OV>

return {
	for_key_collision = "The key '%*' was returned multiple times simultaneously, which is not allowed in `For` objects.\nInput:\n\tKey: %*\n\tValue: %*\n\nOutput:\n\tKey: %*\n\tValue: %*",
}
