-- Lap.lua
-- Made by BOX_G0D

-- // Class Definition \\
local Lap = {
	Sectors = {}, 
	Corners = {},
	StartTime = nil,
	Time = nil
}

-- // Class Constructor \\
function Lap.new()
	local clone = script:Clone()
	return require(clone)
end

-- // Class Destructor \\
function Lap:Destroy()
	script:Destroy()
end

return Lap

--// EOF \\