local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local Animated = require(package.Animation.Animated)

local peek = require(package.State.peek)

local function delayMover<V>(delay: Types.UsedAs<number>)
	local current = nil
	local activeDelayed = {}

	local function update()
		local now = External.lastUpdateStep()

		for index = #activeDelayed, 1, -1 do
			local data = activeDelayed[index]

			if data.timestamp <= now then
				current = data.goal

				table.remove(activeDelayed, index)

				break
			end
		end

		return #activeDelayed == 0, current
	end

	return function(start: V, target: V)
		local now = External.lastUpdateStep()
		local later = now + peek(delay)

		table.insert(activeDelayed, {
			timestamp = later,
			goal = target,
		})

		current = start

		return update
	end
end

local function Delay<V>(
	scope: Types.Scope,
	target: Types.UsedAs<V>,
	delay: Types.UsedAs<number>
): Types.Animated<V>
	return Animated(scope, target, delayMover(delay))
end

return Delay
