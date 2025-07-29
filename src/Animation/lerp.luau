--!strict
local Oklab = require "../Colour/Oklab"

local function vectorLerp(a: vector, b: vector, alpha: number)
	return a + (b - a) * alpha
end

local LERP_FUNCTIONS = {
	number = math.lerp,
	vector = vectorLerp,
	Color3 = function(a: Color3, b: Color3, alpha: number)
		local okFrom = Oklab.fromSRGB(a)
		local okTarget = Oklab.fromSRGB(b)

		return Oklab.toSRGB(vectorLerp(okFrom, okTarget, alpha))
	end,
	Vector3 = function(a: Vector3, b: Vector3, alpha: number)
		return a:Lerp(b, alpha)
	end,
	Vector2 = function(a: Vector2, b: Vector2, alpha: number)
		return a:Lerp(b, alpha)
	end,
	CFrame = function(a: CFrame, b: CFrame, alpha: number)
		return a:Lerp(b, alpha)
	end,
	UDim = function(a: UDim, b: UDim, alpha: number)
		return UDim.new(
			alpha * (b.Scale - a.Scale) + a.Scale,
			alpha * (b.Offset - a.Offset) + a.Offset
		)
	end,
	UDim2 = function(a: UDim2, b: UDim2, alpha: number)
		return a:Lerp(b, alpha)
	end,
}

local function lerp<V>(from: V, target: V, alpha: number): V
	local dataType = typeof(from)

	if typeof(target) == dataType then
		local interpolator = LERP_FUNCTIONS[dataType] :: ((V, V, number) -> V)?

		if interpolator ~= nil then
			return interpolator(from, target, alpha)
		end
	end

	if alpha < 0.5 then
		return from
	end

	return target
end

return lerp
