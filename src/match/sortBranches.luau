local match = require "./types"

local castToState = require "../core-calc/castToState"

local xtypeof = require "../xtypeof"

local function getTier(branch: match.Branch): number
	local pattern = branch.pattern

	if typeof(pattern) == "function" then
		return 2
	elseif castToState(pattern) ~= nil then
		return 1
	end

	return 0
end

local function branchSorter(a: match.Branch, b: match.Branch): boolean
	if a.priority ~= nil and b.priority ~= nil then -- both branch priorities are present, compare their priorities (lower is better?)
		return a.priority < b.priority
	elseif a.priority ~= nil and b.priority == nil then -- only 'current' branch priority is present, meaning we're comparing to something else that is already a lower tier
		return true
	elseif a.priority == nil and b.priority ~= nil then -- only 'other' branch priority is present, meaning we're comparing to something else that is already a higher tier
		return false
	end

	return getTier(a) < getTier(b)
end

local function sortBranches<T>(all_branches: { _: T, [any]: T }): (T?, { match.Branch<T> })
	local default_branch = all_branches._

	all_branches._ = nil

	local sorted = {}

	for pattern, value in all_branches do
		local priority: number? = nil

		if xtypeof(pattern) == "WrappedPattern" then
			local patterninfo = pattern :: match.WrappedPattern

			priority = patterninfo.priority
			pattern = patterninfo.pattern -- "unwrap" pattern
		end

		table.insert(
			sorted,
			table.freeze {
				pattern = pattern,
				value = value,
				priority = priority,
			}
		)
	end

	table.sort(sorted, branchSorter)

	return default_branch, sorted
end

return sortBranches
