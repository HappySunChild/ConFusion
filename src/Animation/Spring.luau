local package = script.Parent.Parent

local Types = require(package.Types)

local Stopwatch = require(package.Animation.Stopwatch)
local packType = require(package.Animation.packType)
local springCoefficients = require(package.Animation.springCoefficients)
local unpackType = require(package.Animation.unpackType)

local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)
local observe = require(package.Graph.observe)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local destructor = require(package.Memory.destructor)

local EPSILON = 0.00001

local class = {
	type = "spring",
	kind = "state",
}

local METATABLE = table.freeze { __index = class }

local function Spring<V>(
	scope: Types.Scopes,
	goal: Types.UsedAs<V>,
	speed: Types.UsedAs<number>?,
	damping: Types.UsedAs<number>?
): Types.Spring<V>
	speed = speed or 10
	damping = damping or 1

	local newSpring = setmetatable({
		scope = scope,
		_createdAt = os.clock(),
		_internalValue = peek(goal),

		_using = {},
		_users = {},

		_timer = Stopwatch(scope),
		_goal = goal,
		_speed = speed,
		_damping = damping,

		_activeDamping = -1,
		_activeGoal = nil,
		_activeNumSprings = 0,
		_activeSpeed = -1,
		_activeLatestP = {},
		_activeLatestV = {},
		_activeStartP = {},
		_activeStartV = {},
		_activeTargetP = {},
		_activeType = "",

		animating = false,
	}, METATABLE)

	table.insert(scope, destructor(newSpring))

	evaluate(newSpring, true)

	return newSpring
end

function class:onChange(callback)
	return observe(self, callback)
end

function class:_evaluate()
	local goal = self._goal

	if not castToState(goal) then
		self._internalValue = goal

		return false
	end

	depend(self, goal)

	local nextGoal = peek(goal)
	local nextType = typeof(nextGoal)
	local discontinuous = nextType ~= self._activeType

	local stopwatch = self._timer :: Stopwatch.Stopwatch
	local elapsed = peek(stopwatch)

	depend(self, stopwatch)

	local oldValue = self._internalValue
	local newValue

	if discontinuous then
		newValue = nextGoal
	elseif elapsed <= 0 then
		newValue = oldValue
	else
		local posPos, posVel, velPos, velVel =
			springCoefficients(elapsed, self._activeDamping, self._activeSpeed)

		local isMoving = false

		for index = 1, self._activeNumSprings do
			local startP = self._activeStartP[index] :: number
			local targetP = self._activeTargetP[index] :: number

			local startV = self._activeStartV[index] :: number
			local startD = startP - targetP

			local latestD = startD * posPos + startV * posVel
			local latestV = startD * velPos + startV * velVel

			if math.abs(latestD) > EPSILON or math.abs(latestV) > EPSILON then
				isMoving = true
			end

			local latestP = latestD + targetP

			self._activeLatestP[index] = latestP
			self._activeLatestV[index] = latestV
		end

		if not isMoving then
			for index = 1, self._activeNumSprings do
				self._activeLatestP[index] = self._activeTargetP[index]
			end

			stopwatch:pause()
			stopwatch:reset()
		end

		self.animating = isMoving

		newValue = packType(self._activeType, self._activeLatestP)
	end

	local nextSpeed = peek(self._speed)
	local nextDamping = peek(self._damping)

	if
		discontinuous
		or nextGoal ~= self._activeGoal
		or nextSpeed ~= self._activeSpeed
		or nextDamping ~= self._activeDamping
	then
		self._activeTargetP = unpackType(nextGoal)
		self._activeNumSprings = #self._activeTargetP

		if discontinuous then
			self._activeStartP = table.clone(self._activeTargetP)
			self._activeLatestP = table.clone(self._activeTargetP)
			self._activeStartV = table.create(self._activeNumSprings, 0)
			self._activeLatestV = table.create(self._activeNumSprings, 0)
		else
			self._activeStartP = table.clone(self._activeLatestP)
			self._activeStartV = table.clone(self._activeLatestV)
		end

		self._activeType = typeof(nextGoal)
		self._activeGoal = nextGoal
		self._activeDamping = nextDamping
		self._activeSpeed = nextSpeed

		stopwatch:reset()
		stopwatch:unpause()
	end

	self._internalValue = newValue

	return oldValue ~= newValue
end

return Spring
