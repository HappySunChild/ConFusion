local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type SubObject<S, IK, IV, OK, OV> = {
	scope: memory.Scope<S>?,
	input_key: IK,
	input_value: IV,
	roam_keys: boolean,
	roam_values: boolean,
	invalidateInputKey: (SubObject<S, IK, IV, OK, OV>) -> (),
	invalidateInputValue: (SubObject<S, IK, IV, OK, OV>) -> (),
	useOutputPair: (SubObject<S, IK, IV, OK, OV>, calc.Use) -> (OK?, OV?),
}

export type Disassembly<S, IK, IV, OK, OV> = calc.StateObject<{ [OK]: OV }> & {
	populate: (Disassembly<S, IK, IV, OK, OV>, calc.Use, output: { [OK]: OV }) -> (),
}

-- A state object which maps over keys and/or values in another table.
export type For<OK, OV> = {
	type: "For",
	timeliness: "lazy",
} & calc.StateObject<{ [OK]: OV }>

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
) -> For<OK, OV> | { [OK]: OV }

export type ForKeysProcessor<S, IK, OK> = (
	use: calc.Use,
	scope: memory.Scope<S>,
	input_key: IK
) -> OK
export type ForKeysConstructor = <S, IK, IV, OK>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: ForKeysProcessor<S, IK, OK>
) -> For<OK, IV> | { [OK]: IV }

export type ForValuesProcessor<S, IV, OV> = (
	use: calc.Use,
	scope: memory.Scope<S>,
	input_value: IV
) -> OV
export type ForValuesConstructor = <S, IK, IV, OV>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: ForValuesProcessor<S, IV, OV>
) -> For<IK, OV> | { [IK]: OV }

return {
	forKeyCollision = "The key '%s' was returned multiple times simultaneously, which is not allowed in `For` objects.",
}
