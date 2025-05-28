local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)

local scope = Fusion:scoped()
local value1 = scope:Value()
local value2 = scope:Value()

local observer = scope:Observer(value1, value2)
observer:onChange(function(v1, v2)
	print(v1 == value1, v2 == value2)
end)

value1:set(1)
value2:set(2)
