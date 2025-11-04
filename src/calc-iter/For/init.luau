local calc = require "../core-calc/types"
local iter = require "./types"
local memory = require "../core-memory/types"

local Disassembly = require "@self/Disassembly"
local depend = require "../core-graph/depend"
local destructor = require "../core-memory/destructor"
local genericUse = require "../core-use/genericUse"

type Self<S, IK, IV, OK, OV> = iter.For<OK, OV> & {
	_disassembly: iter.Disassembly<OK, OV>,
	_use: calc.Use,
}

local CLASS = table.freeze {
	type = "For",
	kind = "state",
	timeliness = "lazy",

	_evaluate = function<S, IK, IV, OK, OV>(self: Self<S, IK, IV, OK, OV>)
		if self.scope == nil then
			return false
		end

		local output = self._internal_value
		local disassembly = self._disassembly

		depend(self, disassembly)

		table.clear(output)

		disassembly:populate(self._use, output)

		return true
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function For<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	input: calc.UsedAs<{ [IK]: IV }>,
	constructor: (
		memory.Scope<S>,
		initial_key: IK,
		initial_value: IV
	) -> iter.ComputedPair<IK, IV, OK, OV>
): iter.For<OK, OV>
	local new_for = setmetatable({
		scope = scope,
		created_at = os.clock(),
		_internal_value = {},

		_using = {},
		_users = {},

		_disassembly = Disassembly(scope, input, constructor),
	}, METATABLE) :: Self<S, IK, IV, OK, OV>

	new_for._use = genericUse(new_for)

	table.insert(scope, destructor(new_for))

	return new_for
end

return For
