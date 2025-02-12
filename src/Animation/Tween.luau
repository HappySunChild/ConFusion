local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local createStopwatch = require(script.Parent.createStopwatch)
local getTweenAlpha = require(script.Parent.getTweenAlpha)
local getTweenDuration = require(script.Parent.getTweenDuration)
local lerp = require(script.Parent.lerp)

local Observer = require(package.Graph.Observer)

local castToState = require(package.State.castToState)
local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)
local peek = require(package.State.peek)

local Info = Symbols.named 'Info'
local Goal = Symbols.named 'Goal'
local Stopwatch = Symbols.named 'Stopwatch'

local TweenFinish = Symbols.named 'TweenFinish'
local TweenStart = Symbols.named 'TweenStart'
local TweenDuration = Symbols.named 'TweenDuration'

local Elapsed = Symbols.named 'Elapsed'

local TweenClass = {
	[Symbols.Type] = Types.Tween,
	[Symbols.Kind] = Kinds.State,
}

local METATABLE = table.freeze { __index = TweenClass }

local function Tween<V>(goal: Types.UsedAs<V>, info: Types.UsedAs<TweenInfo>)
	local newTween = setmetatable({
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.Internal] = peek(goal),

		[Symbols.Using] = {},
		[Symbols.Users] = {},

		[Info] = info,
		[Goal] = goal,
		[Stopwatch] = createStopwatch(),

		[TweenStart] = nil,
		[TweenFinish] = nil,
		[TweenDuration] = nil,

		[Elapsed] = 0,
	}, METATABLE)

	evaluate(newTween, true)

	return newTween
end

function TweenClass:onChange(callback)
	local observer = Observer(self)

	return observer:onChange(callback), observer
end

function TweenClass:_evaluate()
	local goal = self[Goal]

	if not castToState(goal) then
		self[Symbols.Internal] = goal

		return false
	end

	depend(self, goal)

	local finish = peek(goal)
	local info = peek(self[Info])

	local stopwatch = self[Stopwatch]

	if finish ~= self[TweenFinish] then
		self[TweenDuration] = getTweenDuration(info)
		self[TweenStart] = self[Symbols.Internal]
		self[TweenFinish] = finish

		stopwatch:reset()
		stopwatch:unpause()
	end

	depend(self, stopwatch)

	self[Elapsed] = peek(stopwatch)

	if self[TweenStart] == self[TweenFinish] or self[Elapsed] > self[TweenDuration] then
		self[TweenStart] = self[TweenFinish]
		self[Elapsed] = self[TweenDuration]

		stopwatch:pause()
	end

	local alpha = getTweenAlpha(info, self[Elapsed])
	local oldValue = self[Symbols.Internal]
	local newValue = lerp(self[TweenStart], self[TweenFinish], alpha)

	self[Symbols.Internal] = newValue

	return newValue ~= oldValue
end

table.freeze(TweenClass)

return Tween
