-- RegionPlus.lua

-- // Class Definition \\
local Region = {
	CheckPlayerEntry = false,
	PlayersInRegion = {},
	PlayerEnteredRegion = script.PlayerEnteredRegion, -- Bindable Event named PlayerEnteredRegion
	PlayerExitedRegion = script.PlayerExitedRegion, -- Bindable Event named PlayerExitedRegion
	Size = Vector3.new(1,1,1),
	Transform = nil
}

-- // Private functions \\

--- Returns a table of all the players in a given region
---@param partsInRegion table
local function filterPlayersInRegion(partsInRegion)
	local tempTable = {};

	for _,v in pairs(partsInRegion) do
		if game:GetService("Players"):GetPlayerFromCharacter(v.Parent) and not table.find(tempTable, game:GetService("Players"):GetPlayerFromCharacter(v.Parent)) then
			table.insert(tempTable, game:GetService("Players"):GetPlayerFromCharacter(v.Parent));
		end
	end

	return tempTable;
end

--- Checks if the new player was added to the table of players
--- @param filteredTable table
local function checkPlayersAdded(filteredTable)
	for _,v in pairs(Region.PlayersInRegion) do
		if not table.find(filteredTable, v) then
			Region.PlayerExitedRegion:Fire(v);
			table.remove(Region.PlayersInRegion, table.find(Region.PlayersInRegion, v));
		end
	end
end

--- Checks if a player was removed from a table of players
--- @param filteredTable table
local function checkPlayersRemoved(filteredTable)
	for _,v in pairs(filteredTable) do
		if not table.find(Region.PlayersInRegion, v) then
			Region.PlayerEnteredRegion:Fire(v);
			table.insert(Region.PlayersInRegion, v);
		end
	end
end

--- Create a new BindableEvent object
---@param name string
---@param parent any
local function createEvent(name: string, parent)
	local object = Instance.new("BindableEvent");
	object.Name = name;
	object.Parent = parent;
end

-- // Public functions \\

--- Creates region data based on a BSP object
---@param BSP any
---@param DestroyBSP boolean
function Region:CreateRegionFromBSP(BSP: BasePart, DestroyBSP: boolean) 
	Region.Size = BSP.Size;
	Region.Transform = BSP.CFrame;

	if DestroyBSP or DestroyBSP == nil then
		BSP:Destroy();
	end
end

-- // Class constructor \\
function Region.new()
	local clone = script:Clone();

	-- Initialize new objects if necessary
	if clone["PlayerEnteredRegion"] == nil then
		createEvent("PlayerEnteredRegion", clone);
	end

	if clone["PlayerExitedRegion"] == nil then
		createEvent("PlayerExitedRegion", clone);
	end

	return require(clone);
end

-- // Class destructor \\
function Region:Destroy()
	script:Destroy();
end

-- // Frame tick \\
game:GetService("RunService").Heartbeat:Connect(function()
	if Region.CheckPlayerEntry then
		local filteredTable = filterPlayersInRegion(workspace:GetPartBoundsInBox(Region.Transform, Region.Size))
		if filteredTable ~= Region.PlayersInRegion then
			checkPlayersAdded(filteredTable);
			checkPlayersRemoved(filteredTable);
		end
	end
end)

return Region;

--// EOF \\