local package = script.Parent.Parent

local destroy = require(package.Memory.destruct)

local function destructor(target)
	return function()
		destroy(target)
	end
end

return destructor
