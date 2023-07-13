-- Timing.lua
-- Made by BOX_G0D

-- // Class Definition \\
local Timing = {
	Player = nil,
	LapAdded = script.LapAdded.Value,
	SectorAdded = script.SectorAdded.Value,
	IntervalChanged = script.IntervalChanged.Value,
	PositionUpdated = script.PositionUpdated.Value,
	CurrentLap = nil,
	BestLap = nil,
	Laps = {},
}

-- // Variables \\
local Regions = {Sectors = {}, Corners = {}};
local RegionPlus = require(script.RegionPlus);
local Standings = require(script.Standings.Value);
local Lap = require(script.Lap);
local Connections = {Sectors = {}};

-- // Private functions \\

--- Create a new BindableEvent object
---@param name string
---@param parent any
local function createEvent(name: string, parent)
	local object = Instance.new("BindableEvent");
	object.Name = name;
	object.Parent = parent;
end

--- Creates a new Region
---@param regionSection table
---@param instance BasePart
---@param deleteBSP boolean
local function createRegion(regionSection, instance: BasePart, deleteBSP: boolean)
	local region = RegionPlus.new();
	region:CreateRegionFromBSP(instance, deleteBSP);
	region.CheckPlayerEntry = true;
	table.insert(regionSection, region);
end

--- Set up the tables with the corners times and regions
local function setupCorners()
	table.clear(Regions.Corners)
	for i,v in pairs(script.Corners.Value:GetChildren()) do
		if Timing[v:GetAttribute("Corner_Number")] then
			Timing[v:GetAttribute("Corner_Number")] = os.clock();
			createRegion(Regions.Corners, v, true);
		end
	end
end

--- Set up the tables with the sectors times and regions
local function setupSectors()
	table.clear(Regions.Sectors);
	createRegion(Regions.Sectors, script.Start.Value, true);
	createRegion(Regions.Sectors, script.S2.Value, true);
	createRegion(Regions.Sectors, script.S3.Value, true);
end

--- Checks if you went through in the correct order
---@param sectorNumber number
local function checkSector(sectorNumber: number)
	if sectorNumber == 1 then
		if Timing.Laps[#Timing.Laps].Sectors[1] then
			return false;
		else
			return true;
		end
	elseif sectorNumber > 1 then
		if Timing.Laps[#Timing.Laps].Sectors[sectorNumber] or not Timing.Laps[#Timing.Laps].Sectors[sectorNumber - 1] then
			return false;
		else
			return true;
		end
	end
end

--- Checks if you can enter a sector
---@param sectorNumber number
local function sectorEnteredValid(sectorNumber: number)
	if sectorNumber == 1 then
		if #Timing.Laps == 0 then
			return true;
		else
			return checkSector(3);
		end
	else if sectorNumber == 2 or sectorNumber == 3 then
			return checkSector(sectorNumber - 1);
		end
	end
end

--- Connects the events for each sector and records the times when entered
local function recordSectorTimes()
	local Laps = Timing.Laps;
	local currentLap;
	local startTime, s1Time, s2Time, s3Time, lapTime;

	for i,v in pairs(Regions.Sectors) do
		Regions.Sectors[i].PlayerEnteredRegion.Event:Connect(function(player)
			if player == Timing.Player then
				if sectorEnteredValid(i) then
					if i == 1 then
						if #Laps > 0 then
							currentLap.Sectors[3] = Timing:GetSectorTime(currentLap, 3);
							currentLap.Time = Timing:GetLapTime(#Laps);
							Timing.SectorAdded:Fire(Timing.Player, 3, Timing:GetSectorTime(currentLap, 3));
							Timing.LapAdded:Fire(Timing.Player, currentLap.Time, #Laps);
						end
						local Lap = Lap.new();
						Lap.StartTime = os.clock();
						table.insert(Laps, Lap);
						currentLap = Lap;
					else
						currentLap.Sectors[i-1] = Timing:GetSectorTime(currentLap, i-1);
						Timing.SectorAdded:Fire(Timing.Player, i-1, Timing:GetSectorTime(currentLap, i-1));
					end
				end
			end
		end)
	end
end

--- Adds players to Timing.Standings when they join the game or if they arent already in there.
local function setupStandings()
	for _,v in pairs(game.Players:GetPlayers()) do
		table.insert(Standings.Players, v);
	end
	game.Players.PlayerAdded:Connect(function(player)
		table.insert(Standings.Players, player);
	end)
end

-- // Public Functions \\

--- Gets the total time for a given sector
---@param Lap any
---@param Sector number
function Timing:GetSectorTime(Lap, Sector: number)
	if Sector == 1 then
		return os.clock() - Lap.StartTime;
	elseif Sector == 2 then
		return os.clock() - Lap.StartTime - Lap.Sectors[1];
	elseif Sector == 3 then
		return os.clock() - Lap.StartTime - Lap.Sectors[1] - Lap.Sectors[2];
	else
		error("Invalid number passed as sector");
	end
end

--- Gets the total lap time for a given lap
---@param lapNumber any
function Timing:GetLapTime(lapNumber: number)
	local Lap = Timing.Laps[lapNumber];
	return Lap.Sectors[1] + Lap.Sectors[2] + Lap.Sectors[3];
end

--- Starts recording and setting up the timing system
function Timing:Start()
	setupCorners();
	setupSectors();
	setupStandings();

	recordSectorTimes();
end

--- Clears the times of all players in game
function Timing:ClearAllTimes()
	for _,v in pairs(game:GetService("Players"):GetPlayers()) do
		require(v.Timing):ClearTimes();
	end
end

--- Clears the times of Timing.Player
function Timing:ClearTimes()
	for _,v in pairs(Timing.Laps) do
		v:Destroy();
	end
	table.clear(Timing.Laps);
	Timing.CurrentLap = nil;
	Timing.BestLap = nil;
end

-- // Class Constructor \\
---@param player Player
function Timing.new(player: Player)
	local clone = script:Clone();
	clone.Parent = player;

	if clone["LapAdded"] == nil then
		createEvent("LapAdded", clone);
	end

	if clone["SectorAdded"] == nil then
		createEvent("SectorAdded", clone);
	end
	local required_clone = require(clone);
	required_clone.Player = player;
	return required_clone;
end

-- // Class Destructor \\
function Timing:Destroy()
	for _,v in pairs(Regions) do
		v:Destroy();
	end
	Timing:ClearTimes();
	script:Destroy();
end

return Timing

-- // EOF \\