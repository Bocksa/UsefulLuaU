-- | Variables
local Region = {
	CheckPlayerEntry = false,
	PlayersInRegion = {},
	PlayerEnteredRegion = script.PlayerEnteredRegion, -- Bindable Event named PlayerEnteredRegion
	PlayerExitedRegion = script.PlayerExitedRegion, -- Bindable Event named PlayerExitedRegion
	size = Vector3.new(1,1,1),
	cFrame = nil
}

-- | Private Functions
local function filterPlayersInRegion(partsInRegion) -- Returns a table of all the players in a given region
	local temp_table = {}
	for _,v in pairs(partsInRegion) do
		if game:GetService("Players"):GetPlayerFromCharacter(v.Parent) and not table.find(temp_table, game:GetService("Players"):GetPlayerFromCharacter(v.Parent)) then
			table.insert(temp_table, game:GetService("Players"):GetPlayerFromCharacter(v.Parent))
		end
	end
	return temp_table
end

local function checkPlayersAdded(filteredTable) -- Checks if a new player was added to a table of players
	for _,v in pairs(Region.PlayersInRegion) do
		if not table.find(filteredTable, v) then
			Region.PlayerExitedRegion:Fire(v)
			table.remove(Region.PlayersInRegion, table.find(Region.PlayersInRegion, v))
		end
	end
end

local function checkPlayersRemoved(filteredTable) -- Checks if a player was removed from a table of players
	for _,v in pairs(filteredTable) do
		if not table.find(Region.PlayersInRegion, v) then
			Region.PlayerEnteredRegion:Fire(v)
			table.insert(Region.PlayersInRegion, v)
		end
	end
end

-- | Public Functions
function Region.new()
	return require(script:Clone())
end

function Region:CreateRegionFromBSP(BSP: BasePart, DestroyBSP: boolean) -- Creates region data based on BSP object data and destroys it given a passed argument
	Region.size = BSP.Size
	Region.cFrame = BSP.CFrame
	if DestroyBSP or DestroyBSP == nil then
		BSP:Destroy()
	end
end

-- | Main
game:GetService("RunService").Heartbeat:Connect(function() -- Checks if a player has entered a region every tick
	if Region.CheckPlayerEntry then
		local filteredTable = filterPlayersInRegion(workspace:GetPartBoundsInBox(Region.cFrame, Region.size))
		if filteredTable ~= Region.PlayersInRegion then
			checkPlayersAdded(filteredTable)
			checkPlayersRemoved(filteredTable)
		end
	end
end)

return Region