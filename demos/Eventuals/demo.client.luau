local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local observe, peek = Fusion.observe, Fusion.peek

local scope = Fusion:scoped()

local cooldownActive = scope:Value(false)
local val = scope:Eventual(function(use, become: (V) -> ())
	for i = 10, 1, -1 do
		if not use(cooldownActive) then
			return become "Inactive"
		end

		become(i)

		task.wait(1)
	end

	return become "Done"
end)

observe(val, function()
	print("changed", peek(val))
end, true)

task.wait(1)

cooldownActive:set(true)

task.wait(5)

cooldownActive:set(false)
