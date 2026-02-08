local types = require("../types")

local function test_error_handler(err: types.Error | string): types.Error
	if typeof(err) == "string" then
		return {
			type = "generic_error",
			message = err,
			trace = debug.traceback(nil, 3),
		}
	end

	return err
end

local function run_test(test: types.Test): types.TestRunResult
	local start_time = os.clock()
	local ok, err: types.Error = xpcall(test.body, test_error_handler, test)

	local result: types.TestRunResult = {
		status = if ok then "pass" else "fail",
		duration = os.clock() - start_time,
		error = err,
	}

	return result
end

return run_test
