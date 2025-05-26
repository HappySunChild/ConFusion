local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Observer = require(ReplicatedStorage.Libraries.ConFusion.Graph.Observer)

local observe = Fusion.observe

local scope = Fusion:scoped { Observer = Observer }
local timer = scope:Timer()
local color = scope:Computed(function(use: Fusion.Use)
	local now = use(timer)

	return Color3.fromHSV(now % 1, 1, 1)
end)

-- observe(color, function()
-- 	print "color updated"
-- end)

scope:Observer(color):onChange(function()
	print "color updated"
end)
