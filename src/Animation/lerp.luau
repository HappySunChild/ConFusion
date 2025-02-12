local package = script.Parent.Parent

local Oklab = require(package.Colors.Oklab)

local function lerp<V>(from: V, target: V, alpha: number) : V
	local dataType = typeof(from)
	
	if typeof(target) == dataType then
		if dataType == 'number' then
			return (target - from) * alpha + from
		elseif dataType == 'Color3' then
			local okFrom = Oklab.fromSRGB(from)
			local okTarget = Oklab.fromSRGB(target)
			
			return Oklab.toSRGB(okFrom:Lerp(okTarget, alpha))
		elseif dataType == 'Vector3' then
			return from:Lerp(target, alpha)
		elseif dataType == 'Vector2' then
			return from:Lerp(target, alpha)
		elseif dataType == 'CFrame' then
			return from:Lerp(target, alpha)
		elseif dataType == 'UDim' then
			return UDim.new(
				lerp(from.Scale, target.Scale, alpha),
				lerp(from.Offset, target.Scale, alpha)
			)
		elseif dataType == 'UDim2' then
			return from:Lerp(target, alpha)
		end
	end
	
	if alpha < 0.5 then
		return from
	else
		return target
	end
end

return lerp