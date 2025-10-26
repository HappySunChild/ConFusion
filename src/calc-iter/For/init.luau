local calc = require "../core-calc/types"
local iter = require "./types"
local memory = require "../core-memory/types"

local destructor = require "../core-memory/destructor"

local depend = require "../core-graph/depend"

local genericUse = require "../core-use/genericUse"

local Disassembly = require "@self/Disassembly"

type Self<S, IK, IV, OK, OV> = iter.For<OK, OV> & {
	_disassembly: iter.Disassembly<S, IK, IV, OK, OV>,
	_use: calc.Use,
}

local class = table.freeze {
	type = "For",
	kind = "state",
	timeliness = "lazy",

	_evaluate = function<S, IK, IV, OK, OV>(self: Self<S, IK, IV, OK, OV>)
		if self.scope == nil then
			return false
		end

		local output = self._internalValue
		local disassembly = self._disassembly

		depend(self, disassembly)

		table.clear(output)

		disassembly:populate(self._use, output)

		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function For<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	input: calc.UsedAs<{ [IK]: IV }>,
	constructor: (
		memory.Scope<S>,
		initialKey: IK,
		initialValue: IV
	) -> iter.SubObject<S, IK, IV, OK, OV>
): iter.For<OK, OV>
	local new_for = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = {},

		_using = {},
		_users = {},

		_disassembly = Disassembly(scope, input, constructor),
	}, METATABLE) :: Self<S, IK, IV, OK, OV>

	new_for._use = genericUse(new_for)

	table.insert(scope, destructor(new_for))

	return new_for
end

return For
