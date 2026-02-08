local types = require("../types")

local format_duration = require("./format_duration")

type FormattedResult = {
	test: types.Test,
	result: types.TestRunResult,
	icon: string,

	full_label: string,
	annotations: string,
}

type FmtOptions = {
	disable_unicode: boolean?,
	disable_emoji: boolean?,
	disable_color: boolean?,

	line_width: number?,
}

local ANSI_RESET = "\x1b[0m"

local function results_formatter(options: FmtOptions)
	local DISABLE_UNICODE = options.disable_unicode
	local DISABLE_EMOJI = options.disable_emoji
	local DISABLE_COLOR = options.disable_color

	local function bind_tint(...: string)
		local ansi_code = `\x1b[{table.concat({ ... }, ";")}m`

		return function(text: any): string
			return if DISABLE_COLOR
				then tostring(text)
				else ansi_code .. tostring(text) .. ANSI_RESET
		end
	end

	-- COLORS
	local dim = bind_tint("2", "90")
	local pass_bright = bind_tint("92")
	local pass = bind_tint("32")
	local fail_bright = bind_tint("91")
	local fail = bind_tint("31")
	local trace = bind_tint("95")
	local trace_dim = bind_tint("2", "35")

	local tint_number = bind_tint("1", "36")
	local tint_string = bind_tint("33")
	local tint_keyword = bind_tint("1", "35")
	local tint_bool = bind_tint("1", "94")

	local function syntax(snippet: string): string
		local formatted = snippet
			:gsub("0?[xXbB]?%d*%.?%d*[eE]?%-?%d+", tint_number)
			:gsub('".-"', tint_string)
			:gsub("'.-'", tint_string)
			:gsub("function", tint_keyword)
			:gsub("end", tint_keyword)
			:gsub("true", tint_bool)
			:gsub("false", tint_bool)
			:gsub("nil", tint_keyword)
			:gsub("%-%-.-\n", dim)

		return formatted
	end

	local LINE_WIDTH = options.line_width or 80

	local DIVIDER = if DISABLE_UNICODE then "=" else "═"
	local MARGIN_LINE = if DISABLE_UNICODE then "|" else "│"
	local ARROW = if DISABLE_UNICODE then ">" else "▸"

	local PASS_ICON = if DISABLE_EMOJI
		then pass_bright(if DISABLE_UNICODE then "[PASS]" else "✔")
		else "✅"
	local FAIL_ICON = if DISABLE_EMOJI
		then fail_bright(if DISABLE_UNICODE then "[FAIL]" else "✖")
		else "❌"

	local function title(text: string)
		local no_ansi = text:gsub("\x1b.-m", "")
		local divider_count = (LINE_WIDTH - string.len(no_ansi) - 2) / 2
		local divider_lhs = dim(string.rep(DIVIDER, math.floor(divider_count)))
		local divider_rhs = dim(string.rep(DIVIDER, math.ceil(divider_count)))

		return `{divider_lhs} {text} {divider_rhs}`
	end

	local FULL_DIVIDER = dim(string.rep(DIVIDER, LINE_WIDTH))

	local function fmt(units_results: types.UnitsRunResult): string
		local lines = {}

		local pretty_results: { FormattedResult } = {}

		for _, unit_result in units_results.individual_units do
			for test, test_result in unit_result.individual do
				local status_emoji = if test_result.status == "pass" then PASS_ICON else FAIL_ICON
				local annotations = {
					"",
					format_duration(test_result.duration),
				}

				table.insert(pretty_results, {
					test = test,
					result = test_result,
					icon = status_emoji,

					full_label = `{unit_result.label} {ARROW} {test.label}`,
					annotations = dim(table.concat(annotations, " - ")),
				})
			end
		end

		-- ERRORS

		if units_results.total_tally.fail > 0 then
			table.insert(lines, title(`Errors from {units_results.total_tally.fail} test(s)`))
			table.insert(lines, "")

			for _, pretty in pretty_results do
				local err = pretty.result.error

				if err == nil then
					continue
				end

				table.insert(lines, `{pretty.icon} {pretty.full_label}`)
				table.insert(lines, trace(err.message))

				local snippet = err.code

				if snippet ~= nil then
					local line = tostring(err.line or "??")
					local empty_margin = string.rep(" ", #line + 1) .. dim(MARGIN_LINE)

					local formatted_snippet = syntax(snippet):gsub(
						"[^\n\r]+[\n\r]",
						function(line: string)
							return `{line}{empty_margin} `
						end
					)

					table.insert(lines, empty_margin)
					table.insert(lines, `{trace(line)} {dim(MARGIN_LINE)} {formatted_snippet}`)
					table.insert(lines, empty_margin)
				end

				table.insert(lines, trace_dim(err.trace))
				table.insert(lines, "")
			end
		end

		-- STATUS

		table.insert(lines, title(`Status of {#pretty_results} test(s)`))
		table.insert(lines, "")

		for _, pretty in pretty_results do
			table.insert(lines, `{pretty.icon} {pretty.full_label}{pretty.annotations}`)
		end

		table.insert(lines, "")

		-- CONCLUSION

		local total_tally = units_results.total_tally

		table.insert(
			lines,
			title(`{pass(total_tally.pass)} passed, {fail(total_tally.fail)} failed`)
		)

		local line_items = {}

		local function add_line_item(key: string, value: string)
			table.insert(line_items, `{dim(key .. ":")} {value}`)
		end

		add_line_item("Total Duration", tint_string(format_duration(units_results.total_duration)))

		table.insert(lines, "")

		for _, item in line_items do
			table.insert(lines, item)
		end

		table.insert(lines, "")
		table.insert(lines, FULL_DIVIDER)

		return table.concat(lines, "\n")
	end

	return fmt
end

return results_formatter
