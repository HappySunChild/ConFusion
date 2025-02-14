local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local getTweenAlpha = require(script.Parent.getTweenAlpha)
local getTweenDuration = require(script.Parent.getTweenDuration)
local lerp = require(script.Parent.lerp)

local Observer = require(package.Graph.Observer)
local Stopwatch = require(package.Animation.Stopwatch)

local castToState = require(package.State.castToState)
local depend = require(package.Graph.depend)
local destructor = require(package.Memory.destructor)
local evaluate = require(package.Graph.evaluate)
local peek = require(package.State.peek)

local Info = Symbols.named 'Info'
local Goal = Symbols.named 'Goal'
local _Stopwatch = Symbols.named 'Stopwatch'

local TweenFinish = Symbols.named 'TweenFinish'
local TweenStart = Symbols.named 'TweenStart'
local TweenDuration = Symbols.named 'TweenDuration'

local Elapsed = Symbols.named 'Elapsed'

local class = {
	[Symbols.Type] = 'tween',
	[Symbols.Kind] = 'state',
}

local METATABLE = table.freeze { __index = class }

local function Tween<V>(scope: Types.Scope, goal: Types.UsedAs<V>, info: Types.UsedAs<TweenInfo>)
	local newTween = setmetatable({
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.InternalValue] = peek(goal),

		[Symbols.Using] = {},
		[Symbols.Users] = {},

		[Info] = info,
		[Goal] = goal,
		[_Stopwatch] = Stopwatch(scope),

		[TweenStart] = nil,
		[TweenFinish] = nil,
		[TweenDuration] = nil,

		[Elapsed] = 0,
	}, METATABLE)

	table.insert(scope, destructor(newTween))

	evaluate(newTween, true)

	return newTween
end

function class:onChange(callback)
	local observer = Observer(self[Symbols.Scope], self)

	return observer:onChange(callback), observer
end

function class:_evaluate()
	local goal = self[Goal]

	if not castToState(goal) then
		self[Symbols.InternalValue] = goal

		return false
	end

	depend(self, goal)

	local finish = peek(goal)
	local info = peek(self[Info])

	local stopwatch = self[_Stopwatch]

	if finish ~= self[TweenFinish] then
		self[TweenDuration] = getTweenDuration(info)
		self[TweenStart] = self[Symbols.InternalValue]
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
	local oldValue = self[Symbols.InternalValue]
	local newValue = lerp(self[TweenStart], self[TweenFinish], alpha)

	self[Symbols.InternalValue] = newValue

	return newValue ~= oldValue
end

table.freeze(class)

return Tween
