local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local External = {}
local boundCallbacks = {}

function External.unbindAll()
	table.clear(boundCallbacks)
end

function External.bind(callback: (now: number, () -> nil) -> nil)
	local function disconnect()
		boundCallbacks[callback] = nil
	end
	
	boundCallbacks[callback] = disconnect
	
	return disconnect
end

function External.step()
	local now = os.clock()
	
	for callback, disconnect in boundCallbacks do
		callback(now, disconnect)
	end
end

if RunService:IsClient() then
	local id = 'ReactFusionStep-' .. HttpService:GenerateGUID(false)
	
	RunService:BindToRenderStep(id, Enum.RenderPriority.First.Value, External.step)
else
	RunService.Heartbeat:Connect(External.step)
end

return External