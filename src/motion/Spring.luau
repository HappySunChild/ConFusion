local calc = require "../calc/types"
local memory = require "../memory/types"
local motion = require "./types"

local Animated = require "./Animated"
local packType = require "./packType"
local springCoefficients = require "./springCoefficients"
local unpackType = require "./unpackType"

local peek = require "../use/peek"

local EPSILON = 0.0001

local function springMover(speed: calc.UsedAs<number>, damping: calc.UsedAs<number>)
	local startP = {}

	local currentP = {}
	local currentV = {}

	local activeType = ""

	return function<V>(start: V, target: V, initialVelocity: { number }?)
		local discontinuous = typeof(target) ~= activeType

		activeType = typeof(target)

		local targetP = unpackType(target)
		local numSprings = #targetP

		if discontinuous then
			startP = table.clone(targetP)
			currentP = table.clone(targetP)

			initialVelocity = table.create(numSprings, 0)
			currentV = table.create(numSprings, 0)
		else
			startP = table.clone(currentP)
		end

		-- spring stepper
		return function(elapsed: number): V
			local shouldSleep = false
			local newValue

			if elapsed <= 0 then
				newValue = start
			else
				local posPos, posVel, velPos, velVel =
					springCoefficients(elapsed, peek(damping), peek(speed))

				local isMoving = false

				for index = 1, numSprings do
					local startP = startP[index] :: number
					local targetP = targetP[index] :: number

					local startV = initialVelocity[index] :: number
					local startD = startP - targetP

					local latestD = startD * posPos + startV * posVel
					local latestV = startD * velPos + startV * velVel

					if latestD ~= latestD or latestV ~= latestV then
						latestD, latestV = 0, 0
					end

					if math.abs(latestD) > EPSILON or math.abs(latestV) > EPSILON then
						isMoving = true
					end

					local latestP = latestD + targetP

					currentP[index] = latestP
					currentV[index] = latestV
				end

				if not isMoving then
					for index = 1, numSprings do
						currentP[index] = targetP[index]
					end
				end

				shouldSleep = not isMoving
				newValue = packType(activeType, currentP)
			end

			return shouldSleep, newValue, currentV
		end
	end
end

local function Spring<V>(
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	speed: calc.UsedAs<number>?,
	damping: calc.UsedAs<number>?
): motion.Animated<V>
	return Animated(scope, goal, springMover(speed or 10, damping or 1))
end

return Spring
