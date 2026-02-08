local types = require("../types")

local run_test = require("../test/run_test")

type DefineTest = (description: string, test_body: TestBody) -> ()

type TestBody = () -> ()
type UnitBody = (test: DefineTest) -> ()

local function unit(label: string, tests: { types.Test }): () -> types.UnitRunResult
	local function run_unit(): types.UnitRunResult
		local tally = {
			pass = 0,
			fail = 0,
		}

		local individual: { [types.Test]: types.TestRunResult } = {}

		local start_time = os.clock()

		for _, test in tests do
			local test_result = run_test(test)

			individual[test] = test_result

			if test_result.status == "pass" then
				tally.pass += 1
			else
				tally.fail += 1
			end
		end

		return {
			label = label,
			duration = os.clock() - start_time,

			individual = individual,
			tally = tally,
		}
	end

	return run_unit
end

return unit
