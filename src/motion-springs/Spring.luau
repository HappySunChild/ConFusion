local calc = require "../core-calc/types"
local memory = require "../core-memory/types"
local motion = require "../motion/types"

local peek = require "../core-use/peek"

local Motion = require "../motion/Motion"

local packType = require "./packType"
local springCoefficients = require "./springCoefficients"
local unpackType = require "./unpackType"

local EPSILON = 0.0001

local function SpringMover<T>(
	speed: calc.UsedAs<number>,
	damping: calc.UsedAs<number>
): motion.MoveGenerator<T>
	local current_v = {}

	local active_type = ""

	local curve_generator = function(
		target_position: T,
		initial_position: T,
		initial_velocity: { number }?
	): motion.AnimationMove<T>
		local discontinuous = typeof(target_position) ~= active_type

		active_type = typeof(target_position)

		local start_p = unpackType(initial_position)
		local target_p = unpackType(target_position)

		local spring_count = #target_p

		if discontinuous then
			start_p = table.clone(target_p)

			initial_velocity = table.create(spring_count, 0)
			current_v = table.create(spring_count, 0)
		end

		local current_p = table.clone(start_p)

		local new_curve = function(elapsed: number): (boolean, T, { number })
			local should_sleep = false
			local new_value

			if elapsed <= 0 then
				new_value = initial_position
			else
				local pos_pos, pos_vel, vel_pos, vel_vel =
					springCoefficients(elapsed, peek(damping), peek(speed))

				local is_moving = false

				for index = 1, spring_count do
					local start_p = start_p[index] :: number
					local target_p = target_p[index] :: number

					local start_v = initial_velocity[index] :: number
					local start_d = start_p - target_p

					local latest_d = start_d * pos_pos + start_v * pos_vel
					local latest_v = start_d * vel_pos + start_v * vel_vel

					if latest_d ~= latest_d or latest_v ~= latest_v then
						latest_d, latest_v = 0, 0
					end

					if math.abs(latest_d) > EPSILON or math.abs(latest_v) > EPSILON then
						is_moving = true
					end

					local latest_p = latest_d + target_p

					current_p[index] = latest_p
					current_v[index] = latest_v
				end

				if not is_moving then
					for index = 1, spring_count do
						current_p[index] = target_p[index]
					end
				end

				should_sleep = not is_moving
				new_value = packType(active_type, current_p)
			end

			return should_sleep, new_value, current_v
		end

		return new_curve
	end

	return curve_generator
end

local function Spring<T>(
	scope: memory.Scope,
	goal: calc.UsedAs<T>,
	speed: calc.UsedAs<number>?,
	damping: calc.UsedAs<number>?
): motion.Motion<T>
	return Motion(scope, goal, SpringMover(speed or 10, damping or 1))
end

return Spring
