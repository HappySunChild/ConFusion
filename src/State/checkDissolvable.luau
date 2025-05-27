local Types = require "../Types"

local castToState = require "./castToState"

local doCleanup = require "../Memory/doCleanup"

local function dissolveUse<T>(target: Types.UsedAs<T>): T
	if castToState(target) then
		error "not-dissolvable"
	end

	return target
end

local function checkDissolvable<T, S>(
	scope: Types.Scope<S>,
	processor: (
		use: Types.Use,
		scope: Types.Scope<S>,
		...unknown
	) -> T,
	...: unknown
): (boolean, T?)
	local success, constantValue = pcall(processor, dissolveUse, scope, ...)

	if success then
		return true, constantValue
	end

	doCleanup(scope)

	return false
end

return checkDissolvable
