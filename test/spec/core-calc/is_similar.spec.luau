local is_similar = require("@fusion/core-calc/is_similar")

local butler = require("@spec/butler")
local unit, test, expect = butler.unit, butler.test, butler.expect

return unit("is_similar", {
	test("should return similar for identical values", function()
		local value = 123

		expect(is_similar(value, value)):to_equal(true)
	end),
	test("should return non-similar for different values", function()
		local value_a = 123
		local value_b = 321

		expect(is_similar(value_a, value_b)):to_equal(false)
	end),
	test("should return similar for any NaN values", function()
		local nan_a = 0 / 0
		local nan_b = 0 / 0

		expect(is_similar(nan_a, nan_a)):to_equal(true)
		expect(is_similar(nan_a, nan_b)):to_equal(true)
	end),
	test("should return non-similar for mutable tables", function()
		local initial_tab = { foo = 123, bar = "hello" }
		local similar_tab = { foo = 123, bar = "hello" }
		local different_tab = { foo = 321, bar = "world" }

		expect(is_similar(initial_tab, initial_tab)):to_equal(false)
		expect(is_similar(initial_tab, similar_tab)):to_equal(false)
		expect(is_similar(initial_tab, different_tab)):to_equal(false)
	end),
	test("should return similar for normal userdatas", function()
		local userdata_a = newproxy(false)
		local userdata_b = newproxy(false)
		local userdata_c = newproxy(true)
		local userdata_d = newproxy(true)

		-- test a
		expect(is_similar(userdata_a, userdata_a)):to_equal(true)
		expect(is_similar(userdata_a, userdata_b)):to_equal(false)
		expect(is_similar(userdata_a, userdata_c)):to_equal(false)
		expect(is_similar(userdata_a, userdata_d)):to_equal(false)

		-- test b
		expect(is_similar(userdata_b, userdata_a)):to_equal(false)
		expect(is_similar(userdata_b, userdata_b)):to_equal(true)
		expect(is_similar(userdata_b, userdata_c)):to_equal(false)
		expect(is_similar(userdata_b, userdata_d)):to_equal(false)

		-- test c
		expect(is_similar(userdata_c, userdata_a)):to_equal(false)
		expect(is_similar(userdata_c, userdata_b)):to_equal(false)
		expect(is_similar(userdata_c, userdata_c)):to_equal(true)
		expect(is_similar(userdata_c, userdata_d)):to_equal(false)

		-- test d
		expect(is_similar(userdata_d, userdata_a)):to_equal(false)
		expect(is_similar(userdata_d, userdata_b)):to_equal(false)
		expect(is_similar(userdata_d, userdata_c)):to_equal(false)
		expect(is_similar(userdata_d, userdata_d)):to_equal(true)
	end),
	test("should respect __eq for userdatas", function()
		local expected_output = true

		local function eq()
			return expected_output
		end

		local original = newproxy(true)
		getmetatable(original).__eq = eq

		local same_eq = newproxy(true)
		getmetatable(same_eq).__eq = eq

		local diff_eq = newproxy(true)
		getmetatable(diff_eq).__eq = function()
			return expected_output
		end

		expect(is_similar(original, diff_eq)):to_equal(false)
		expect(is_similar(same_eq, diff_eq)):to_equal(false)
		expect(is_similar(diff_eq, original)):to_equal(false)
		expect(is_similar(diff_eq, same_eq)):to_equal(false)
		expected_output = true
		expect(is_similar(original, original)):to_equal(expected_output)
		expect(is_similar(original, same_eq)):to_equal(expected_output)
		expect(is_similar(same_eq, original)):to_equal(expected_output)
		expect(is_similar(same_eq, same_eq)):to_equal(expected_output)
		expect(is_similar(diff_eq, diff_eq)):to_equal(expected_output)
		expected_output = false
		expect(is_similar(original, original)):to_equal(expected_output)
		expect(is_similar(original, same_eq)):to_equal(expected_output)
		expect(is_similar(same_eq, original)):to_equal(expected_output)
		expect(is_similar(same_eq, same_eq)):to_equal(expected_output)
		expect(is_similar(diff_eq, diff_eq)):to_equal(expected_output)
	end),
	test("should respect __eq for mutable tables", function()
		local expected_output = nil

		local function eq()
			return expected_output
		end

		local original = setmetatable({}, { __eq = eq })
		local same_eq = setmetatable({}, { __eq = eq })
		local diff_eq = setmetatable({}, {
			__eq = function()
				return expected_output
			end,
		})

		expect(is_similar(original, diff_eq)):to_equal(false)
		expect(is_similar(same_eq, diff_eq)):to_equal(false)
		expect(is_similar(diff_eq, original)):to_equal(false)
		expect(is_similar(diff_eq, same_eq)):to_equal(false)
		expected_output = true
		expect(is_similar(original, original)):to_equal(expected_output)
		expect(is_similar(original, same_eq)):to_equal(expected_output)
		expect(is_similar(same_eq, original)):to_equal(expected_output)
		expect(is_similar(same_eq, same_eq)):to_equal(expected_output)
		expect(is_similar(diff_eq, diff_eq)):to_equal(expected_output)
		expected_output = false
		expect(is_similar(original, original)):to_equal(expected_output)
		expect(is_similar(original, same_eq)):to_equal(expected_output)
		expect(is_similar(same_eq, original)):to_equal(expected_output)
		expect(is_similar(same_eq, same_eq)):to_equal(expected_output)
		expect(is_similar(diff_eq, diff_eq)):to_equal(expected_output)
	end),
	test("should respect __eq even when the metatable is locked opaquely", function()
		local expected_output = nil

		local function eq()
			return expected_output
		end

		local original: any = setmetatable(
			{},
			{ __eq = eq, __metatable = "This metatable is locked" }
		)
		local same_eq: any = setmetatable(
			{},
			{ __eq = eq, __metatable = "This metatable is locked" }
		)
		local diff_eq: any = setmetatable({}, {
			__eq = function()
				return expected_output
			end,
			__metatable = "This metatable is locked",
		})

		expect(is_similar(original, diff_eq)):to_equal(false)
		expect(is_similar(same_eq, diff_eq)):to_equal(false)
		expect(is_similar(diff_eq, original)):to_equal(false)
		expect(is_similar(diff_eq, same_eq)):to_equal(false)
		expected_output = true
		expect(is_similar(original, original)):to_equal(expected_output)
		expect(is_similar(original, same_eq)):to_equal(expected_output)
		expect(is_similar(same_eq, original)):to_equal(expected_output)
		expect(is_similar(same_eq, same_eq)):to_equal(expected_output)
		expect(is_similar(diff_eq, diff_eq)):to_equal(expected_output)
		expected_output = false
		expect(is_similar(original, original)):to_equal(expected_output)
		expect(is_similar(original, same_eq)):to_equal(expected_output)
		expect(is_similar(same_eq, original)):to_equal(expected_output)
		expect(is_similar(same_eq, same_eq)):to_equal(expected_output)
		expect(is_similar(diff_eq, diff_eq)):to_equal(expected_output)
	end),
	test("should respect __eq for frozen tables", function()
		local expected_output = true

		local immutable_a = table.freeze(setmetatable({}, {
			__eq = function()
				return expected_output
			end,
		}))
		local immutable_b = table.freeze(setmetatable({}, getmetatable(immutable_a)))
		local immutable_x = table.freeze(setmetatable({}, {
			__eq = function()
				return expected_output
			end,
		}))

		expect(is_similar(immutable_a, immutable_x)):to_equal(false)
		expect(is_similar(immutable_b, immutable_x)):to_equal(false)
		expect(is_similar(immutable_x, immutable_a)):to_equal(false)
		expect(is_similar(immutable_x, immutable_b)):to_equal(false)
		expect(is_similar(immutable_a, immutable_a)):to_equal(expected_output)
		expect(is_similar(immutable_a, immutable_b)):to_equal(expected_output)
		expect(is_similar(immutable_b, immutable_a)):to_equal(expected_output)
		expect(is_similar(immutable_b, immutable_b)):to_equal(expected_output)
		expect(is_similar(immutable_x, immutable_x)):to_equal(expected_output)
		expected_output = not expected_output
		expect(is_similar(immutable_a, immutable_a)):to_equal(expected_output)
		expect(is_similar(immutable_a, immutable_b)):to_equal(expected_output)
		expect(is_similar(immutable_b, immutable_a)):to_equal(expected_output)
		expect(is_similar(immutable_b, immutable_b)):to_equal(expected_output)
		expect(is_similar(immutable_x, immutable_x)):to_equal(expected_output)
	end),
})
