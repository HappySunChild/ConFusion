local Oklab = require "../colour/Oklab"

local LERP_FUNCTIONS = table.freeze {
	number = math.lerp,
	vector = vector.lerp,
	Color3 = function(a: Color3, b: Color3, alpha: number)
		local a_vec = vector.create(a.R, a.G, a.B)
		local b_vec = vector.create(b.R, b.G, b.B)

		local ok_from = Oklab.fromSRGBToOklab(a_vec)
		local ok_target = Oklab.fromSRGBToOklab(b_vec)

		local ok_result = Oklab.fromOklabToSRGB(vector.lerp(ok_from, ok_target, alpha))

		return Color3.new(ok_result.x, ok_result.y, ok_result.z)
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
} :: { [string]: <T>(a: T, b: T, alpha: number) -> T }

local function lerp<T>(from: T, target: T, alpha: number): T
	local data_type = typeof(from)

	if typeof(target) == data_type then
		local interpolator = LERP_FUNCTIONS[data_type]

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
