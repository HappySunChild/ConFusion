local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local packType = require(package.Animation.packType)
local springCoefficients = require(package.Animation.springCoefficients)
local unpackType = require(package.Animation.unpackType)

local peek = require(package.State.peek)

local EPSILON = 0.00001

local function Spring(speed: Types.UsedAs<number>, damping: Types.UsedAs<number>)
	local startP = {}
	local startV = {}

	local latestP = {}
	local latestV = {}

	local targetP = {}
	local numSprings = 0

	local activeType = ""

	return function(_, target: unknown)
		local discontinuous = typeof(target) ~= activeType

		targetP = unpackType(target)
		numSprings = #targetP

		if discontinuous then
			startP = table.clone(targetP)
			latestP = table.clone(targetP)

			startV = table.create(numSprings, 0)
			latestV = table.create(numSprings, 0)
		else
			startP = table.clone(latestP)
			startV = table.clone(latestV)
		end

		activeType = typeof(target)

		return function(elapsed: number)
			local posPos, posVel, velPos, velVel =
				springCoefficients(elapsed, peek(damping), peek(speed))

			local isMoving = false

			for index = 1, numSprings do
				local startP = startP[index] :: number
				local targetP = targetP[index] :: number

				local startV = startV[index] :: number
				local startD = startP - targetP

				local latestD = startD * posPos + startV * posVel
				local newV = startD * velPos + startV * velVel

				if math.abs(latestD) > EPSILON or math.abs(newV) > EPSILON then
					isMoving = true
				end

				local newP = latestD + targetP

				latestP[index] = newP
				latestV[index] = newV
			end

			return not isMoving, packType(activeType, latestP)
		end
	end
end

return Spring
