local memory = require "./types"

local External = require "../core-external/External"

local function check_lifetime<A, B>(
	a: A,
	b: B,
	scope_b: memory.Scope,
	formatter: (A, B) -> (string, string)
)
	if scope_b then
		External.log_error(memory.use_after_destroy, nil, formatter(a, b))
	end
end

return check_lifetime
