local castToState = require "../core-calc/castToState"

local function categorizeBranches<T>(
	all_branches: { [any]: T, _: T? }
): (T?, { { [any]: T } })
	local default_branch = all_branches._

	all_branches._ = nil

	local literal_branches = {}
	local state_branches = {}
	local predicate_branches = {}
	local categories = { literal_branches, state_branches, predicate_branches }

	for pattern, output_value in all_branches do
		if type(pattern) == "function" then
			predicate_branches[pattern] = output_value
		elseif castToState(pattern) ~= nil then
			state_branches[pattern] = output_value
		else
			literal_branches[pattern] = output_value
		end
	end

	return default_branch, categories
end

return categorizeBranches
