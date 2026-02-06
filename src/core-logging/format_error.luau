local logging = require("./types")

local function format_error(
	message: string,
	error_or_trace: logging.Error | string?,
	...: unknown
)
	local err = if typeof(error_or_trace) == "table" then error_or_trace else nil
	local trace = if typeof(error_or_trace) == "table"
		then error_or_trace.trace
		else error_or_trace

	message = message:format(...)

	if err ~= nil then
		message = message:gsub("ERROR_MESSAGE", err.message)
	else
		message = message:gsub("ERROR_MESSAGE", "unknown error")
	end

	local error_text = `[ConFusion] {message}`

	if trace ~= nil then
		error_text ..= `\n---- Stack trace ----\n{trace}`
	end

	return error_text:gsub("\n", "\n\t")
end

return format_error
