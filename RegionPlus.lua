-- | Variables
local Region = {
	CheckPlayerEntry = false,
	PlayerEnteredRegion = script.PlayerEnteredRegion,
	PlayerExitedRegion = script.PlayerExitedRegion,
	size = Vector3.new(1,1,1),
	cFrame = CFrame.new()
}

local PlayersInRegion = {}

-- | Private Functions
local function filterPartsInRegion(partsInRegion)
	local temp_table = {}
	for _,v in pairs(partsInRegion) do
		if game:GetService("Players"):GetPlayerFromCharacter(v.Parent) and not table.find(temp_table, game:GetService("Players"):GetPlayerFromCharacter(v.Parent)) then
			table.insert(temp_table, game:GetService("Players"):GetPlayerFromCharacter(v.Parent))
		end
	end
	return temp_table
end

local function checkPlayersAdded(filteredTable)
	for _,v in pairs(PlayersInRegion) do
		if not table.find(filteredTable, v) then
			Region.PlayerExitedRegion:Fire(v)
			table.remove(PlayersInRegion, table.find(PlayersInRegion, v))
		end
	end
end

local function checkPlayersRemoved(filteredTable)
	for _,v in pairs(filteredTable) do
		if not table.find(PlayersInRegion, v) then
			Region.PlayerEnteredRegion:Fire(v)
			table.insert(PlayersInRegion, v)
		end
	end
end

-- | Public Functions
function Region.new()
	return require(script:Clone())
end

function Region:CreateRegionFromBSP(BSP: BasePart, DestroyBSP)
	Region.size = BSP.Size
	Region.cFrame = BSP.CFrame
	if DestroyBSP or DestroyBSP == nil then
		BSP:Destroy()
	end
end

-- | Main
game:GetService("RunService").Heartbeat:Connect(function()
	if Region.CheckPlayerEntry then
		local filteredTable = filterPartsInRegion(workspace:GetPartBoundsInBox(Region.cFrame, Region.size))
		if filteredTable ~= PlayersInRegion then
			checkPlayersAdded(filteredTable)
			checkPlayersRemoved(filteredTable)
		end
	end
end)

return Region