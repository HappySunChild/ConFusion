export type Error = {
	type: string,
	message: string,

	trace: string,
	line: number?,
	code: string?,
}

export type UnitRunResult = {
	duration: number,

	label: string,
	individual: { [Test]: TestRunResult },
	tally: { pass: number, fail: number },
}
export type UnitsRunResult = {
	total_duration: number,
	total_tally: { pass: number, fail: number },
	-- total_individual_tests: { [Test]: TestRunResult },

	individual_units: { UnitRunResult },
}
export type TestRunResult = {
	duration: number,

	status: "pass" | "fail",
	error: Error?,
}

export type Test = {
	label: string,
	body: (...any?) -> ...any?,
}

return nil
