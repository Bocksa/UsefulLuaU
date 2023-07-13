-- Standings.lua
-- Made by BOX_G0D

-- // Class Definition \\
local Standings = {
	IntervalChanged = script.IntervalChanged,
	PositionUpdated = script.PositionUpdated,
	PlayerAddedToStandings = script.PlayerAddedToStandings,
	Players = {}
}

--- Adds player to Standings.Players
---@param player Player
local function addPlayerToStandings(player: Player)
	table.insert(Standings.Players, player);
	Standings.PlayerAddedToStandings:Fire(player);
end

--- Returns true or false based on if a players current lap number is higher than lapNumber or is equal to lapNumber
---@param player Player
---@param lapNumber number
local function playerIsOnLapOrHigherLap(player: Player, lapNumber: number)
	if #require(player:FindFirstChild("Timing")).Laps >= lapNumber then
		return true
	else
		return false
	end
end

--- Checks if player is on a higher corner number than cornerNumber on the referenced lap lapNumber
---@param player Player
---@param lapNumber number
---@param cornerNumber number
local function playerIsOnCornerOrHigherCornerOnLap(player: Player, lapNumber: number, cornerNumber: number)
	if playerIsOnLapOrHigherLap(player, lapNumber) then
		if #require(player:FindFirstChild("Timing"))[lapNumber].Corners >= cornerNumber then
			return true
		else
			return false
		end
	end
end

--- Returns the time between player1 and player2 in seconds
---@param player1 Player
---@param player2 Player
function Standings:GetIntervalToPlayer(player1: Player, player2: Player)
	local player1Timing = require(player1:FindFirstChild("Timing"));
	local player2Timing = require(player2:FindFirstChild("Timing"));
	local currentLap = #player1Timing.Laps;
	local currentCorner = #player1Timing.Laps[currentLap].Corners;
	if playerIsOnCornerOrHigherCornerOnLap(player2, currentLap, currentCorner) then
		return player1Timing.Laps[currentLap].Corners[currentCorner] - player2Timing.Laps[currentLap].Corners[currentCorner];
	end
end

--- Returns true or false based on if the player passed is the race leader
---@param player Player
function Standings:IsPlayerLeader(player: Player)
	if table.find(Standings.Players, player) == 1 then
		return true;
	else
		return false;
	end
end


--- Gets the time between the referenced player and the leader
---@param player Player
function Standings:GetIntervalToLeader(player: Player)
	local Timing = require(player:FindFirstChild("Timing"));
	if player ~= Standings.Players[1] then
		local leaderTiming = require(Standings.Players[1]:FindFirstChild("Timing"));
		local playerTiming = require(player:FindFirstChild("Timing"));
		local currentLap = playerTiming.Laps[#Timing.Laps];
		local currentCorner = currentLap.Corners[#currentLap.Corners]
		if not Standings:IsPlayerLeader(player) then
			return playerTiming.Laps[#playerTiming.Laps].Corners[#currentLap.Corners] - leaderTiming.Laps[#playerTiming.Laps].Corners[#currentLap.Corners]
		end
	end
end

--- Clears the Standings.Players table and reinserts all players
function Standings:Reset()
	table.clear(Standings.Players)
	for _,v in pairs(game.Players:GetPlayers()) do
		table.insert(Standings.Players, v)
	end
end

game.Players.PlayerAdded:Connect(addPlayerToStandings);

return Standings

-- // EOF \\