local types = require("../types")

local function test(label: string, body: (...any?) -> ...any?): types.Test
	return {
		label = label,
		body = body,
	}
end

return test
