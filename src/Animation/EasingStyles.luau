--!strict
local Types = require "../Types"

local PI = math.pi
local TAU = PI * 2
local HALF_PI = PI / 2

local C4 = TAU / 3
local C5 = TAU / 4.5

local sin = math.sin
local cos = math.cos
local pow = math.pow
local sqrt = math.sqrt

local function _expInOut(exponent: number)
	local b = pow(2, exponent - 1)

	return function(x: number)
		return if x < 0.5 then b * pow(x, exponent) else 1 - pow(-2 * x + 2, exponent) / 2
	end
end

local new = table.freeze {
	Exponent = function(exponent: number)
		return table.freeze {
			Out = function(x: number)
				return 1 - pow(1 - x, exponent)
			end,
			In = function(x: number)
				return pow(x, exponent)
			end,
			InOut = _expInOut(exponent),
		}
	end,
	Overshoot = function(amplitude: number)
		local P0 = amplitude
		local P1 = amplitude + 1
		local P2 = amplitude * 1.525

		return table.freeze {
			Out = function(x: number)
				return 1 + P1 * pow(x - 1, 3) + P0 * pow(x - 1, 2)
			end,
			In = function(x: number)
				return P1 * pow(x, 3) - P0 * pow(x, 2)
			end,
			InOut = function(x: number)
				return if x < 0.5
					then (pow(2 * x, 2) * ((P2 + 1) * 2 * x - P2)) / 2
					else (pow(2 * x - 2, 2) * ((P2 + 1) * (x * 2 - 2) + P2) + 2) / 2
			end,
		}
	end,
}

local EasingStyles: Types.EasingStyles = table.freeze {
	Constant = table.freeze {
		Out = function()
			return 1
		end,
		In = function()
			return 0
		end,
		InOut = function()
			return 0.5
		end,
	},
	Linear = table.freeze {
		Out = function(x: number)
			return x
		end,
		In = function(x: number)
			return x
		end,
		InOut = function(x: number)
			return x
		end,
	},
	Exponential = table.freeze {
		Out = function(x: number)
			return if x == 1 then 1 else 1 - pow(2, -10 * x)
		end,
		In = function(x: number)
			return if x == 0 then 0 else pow(2, 10 * x - 10)
		end,
		InOut = function(x: number)
			return if x == 0
				then 0
				elseif x == 1 then 1
				else if x < 0.5
					then pow(2, 20 * x - 10) / 2
					else 2 - pow(2, -20 * x + 10) / 2
		end,
	},
	Circular = table.freeze {
		Out = function(x: number)
			return sqrt(1 - pow(x - 1, 2))
		end,
		In = function(x: number)
			return 1 - sqrt(1 - pow(x, 2))
		end,
		InOut = function(x: number)
			return if x < 0.5
				then 1 - sqrt(1 - pow(2 * x, 2)) / 2
				else (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2
		end,
	},
	Sine = table.freeze {
		Out = function(x: number)
			return sin(x * HALF_PI)
		end,
		In = function(x: number)
			return 1 - cos(x * HALF_PI)
		end,
		InOut = function(x: number)
			return -(cos(x * PI) - 1) / 2
		end,
	},
	Back = new.Overshoot(1),
	Elastic = table.freeze {
		Out = function(x: number)
			return if x == 0
				then 0
				elseif x == 1 then 1
				else pow(2, -10 * x) * sin((x * 10 - 10.75) * C4) + 1
		end,
		In = function(x: number)
			return if x == 0
				then 0
				elseif x == 1 then 1
				else -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * C4)
		end,
		InOut = function(x: number)
			return if x == 0
				then 0
				elseif x == 1 then 1
				else if x < 0.5
					then -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * C5)) / 2
					else (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * C5)) / 2 + 1
		end,
	},

	Quad = new.Exponent(2),
	Cubic = new.Exponent(3),
	Quart = new.Exponent(4),
	Quint = new.Exponent(5),

	new = new,
}

return EasingStyles
