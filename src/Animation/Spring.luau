local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Stopwatch = require(package.Animation.Stopwatch)
local castToState = require(package.State.castToState)
local depend = require(package.Graph.depend)
local destructor = require(package.Memory.destructor)
local evaluate = require(package.Graph.evaluate)
local packType = require(package.Animation.packType)
local peek = require(package.State.peek)
local springCoefficients = require(package.Animation.springCoefficients)
local unpackType = require(package.Animation.unpackType)

local Timer = Symbols.named 'Timer'
local Goal = Symbols.named 'Goal'
local Speed = Symbols.named 'Speed'
local Damping = Symbols.named 'Damping'

local ActiveDamping = Symbols.named 'ActiveDamping'
local ActiveGoal = Symbols.named 'ActiveGoal'
local ActiveLatestP = Symbols.named 'ActiveLatestPosition'
local ActiveLatestV = Symbols.named 'ActiveLatestVelocity'
local ActiveStartP = Symbols.named 'ActiveStartPosition'
local ActiveStartV = Symbols.named 'ActiveStartVelocity'
local ActiveTargetP = Symbols.named 'ActiveTargetPosition'
local ActiveNumSprings = Symbols.named 'ActiveNumberSprings'
local ActiveSpeed = Symbols.named 'ActiveSpeed'
local ActiveType = Symbols.named 'ActiveType'

local EPSILON = 0.00001

local class = {
	type = 'spring',
	kind = 'state',
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
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.InternalValue] = peek(goal),

		[Symbols.Using] = {},
		[Symbols.Users] = {},

		[Timer] = Stopwatch(scope),
		[Goal] = goal,
		[Speed] = speed,
		[Damping] = damping,

		[ActiveDamping] = -1,
		[ActiveGoal] = nil,
		[ActiveNumSprings] = 0,
		[ActiveSpeed] = -1,
		[ActiveLatestP] = {},
		[ActiveLatestV] = {},
		[ActiveStartP] = {},
		[ActiveStartV] = {},
		[ActiveTargetP] = {},
		[ActiveType] = '',

		animating = false,
	}, METATABLE)

	table.insert(scope, destructor(newSpring))

	evaluate(newSpring, true)

	return newSpring
end

function class:_evaluate()
	local goal = self[Goal]

	if not castToState(goal) then
		self[Symbols.InternalValue] = goal

		return false
	end

	depend(self, goal)

	local nextGoal = peek(goal)
	local nextType = typeof(nextGoal)
	local discontinuous = nextType ~= self[ActiveType]

	local stopwatch = self[Timer] :: Stopwatch.Stopwatch
	local elapsed = peek(stopwatch)

	depend(self, stopwatch)

	local oldValue = self[Symbols.InternalValue]
	local newValue

	if discontinuous then
		newValue = nextGoal
	elseif elapsed <= 0 then
		newValue = oldValue
	else
		local posPos, posVel, velPos, velVel =
			springCoefficients(elapsed, self[ActiveDamping], self[ActiveSpeed])

		local isMoving = false

		for index = 1, self[ActiveNumSprings] do
			local startP = self[ActiveStartP][index] :: number
			local targetP = self[ActiveTargetP][index] :: number

			local startV = self[ActiveStartV][index] :: number
			local startD = startP - targetP

			local latestD = startD * posPos + startV * posVel
			local latestV = startD * velPos + startV * velVel

			if math.abs(latestD) > EPSILON or math.abs(latestV) > EPSILON then
				isMoving = true
			end

			local latestP = latestD + targetP

			self[ActiveLatestP][index] = latestP
			self[ActiveLatestV][index] = latestV
		end

		if not isMoving then
			for index = 1, self[ActiveNumSprings] do
				self[ActiveLatestP][index] = self[ActiveTargetP][index]
			end

			stopwatch:pause()
			stopwatch:reset()
		end

		self.animating = isMoving

		newValue = packType(self[ActiveType], self[ActiveLatestP])
	end

	local nextSpeed = peek(self[Speed])
	local nextDamping = peek(self[Damping])

	if
		discontinuous
		or nextGoal ~= self[ActiveGoal]
		or nextSpeed ~= self[ActiveSpeed]
		or nextDamping ~= self[ActiveDamping]
	then
		self[ActiveTargetP] = unpackType(nextGoal)
		self[ActiveNumSprings] = #self[ActiveTargetP]

		if discontinuous then
			self[ActiveStartP] = table.clone(self[ActiveTargetP])
			self[ActiveLatestP] = table.clone(self[ActiveTargetP])
			self[ActiveStartV] = table.create(self[ActiveNumSprings], 0)
			self[ActiveLatestV] = table.create(self[ActiveNumSprings], 0)
		else
			self[ActiveStartP] = table.clone(self[ActiveLatestP])
			self[ActiveStartV] = table.clone(self[ActiveLatestV])
		end

		self[ActiveType] = typeof(nextGoal)
		self[ActiveGoal] = nextGoal
		self[ActiveDamping] = nextDamping
		self[ActiveSpeed] = nextSpeed

		stopwatch:reset()
		stopwatch:unpause()
	end

	self[Symbols.InternalValue] = newValue

	return oldValue ~= newValue
end

return Spring
