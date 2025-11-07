local calc = require "../../core-calc/types"

-- not POSIX regex, Lua regex
local function Regex(regex_pattern: calc.UsedAs<string>)
	return function(value: unknown, use: calc.Use)
		if type(value) ~= "string" then
			return false
		end

		return string.match(value, use(regex_pattern)) ~= nil
	end
end

return Regex
