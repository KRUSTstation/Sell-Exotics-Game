local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataEvents = ReplicatedStorage.Remotes:WaitForChild("DataEvents")

local LevelingHandler = {}

local BASE_XP = 100 
local XP_GROWTH = 1.04

function LevelingHandler.GetMaxXp(level)
	return math.floor(BASE_XP * (XP_GROWTH ^ (level - 1) + 0.5))
end

function LevelingHandler.AttemptLevelUp(player)
	local data = LevelingHandler.DataHandler.GetData(player)
	if not data then return false end

	local level = data.Stats.Level
	local xp = data.Stats.XP
	local maxXP = data.Stats.MaxXP

	if xp < maxXP then
		return false
	end

	local numerator = xp * (XP_GROWTH - 1)
	local ratio = numerator / maxXP + 1

	local levelsGained = math.floor(
		math.log(ratio) / math.log(XP_GROWTH)
	)

	if levelsGained <= 0 then
		return false
	end

	local xpSpent =
		maxXP * (XP_GROWTH ^ levelsGained - 1) / (XP_GROWTH - 1)

	local newLevel = level + levelsGained
	local newXP = xp - xpSpent
	local newMaxXP = LevelingHandler.GetMaxXp(newLevel)
	
	LevelingHandler.DataHandler.SetStat(player, "Level", newLevel)
	LevelingHandler.DataHandler.SetStat(player, "MaxXP", newMaxXP)
	LevelingHandler.DataHandler.SetStat(player, "XP", newXP)

	return true
end

function LevelingHandler.Init(dataHandler)
	if not dataHandler then return end
	
	LevelingHandler.DataHandler = dataHandler
	
	print('[LevelingHandler] LevelingHandler initialised')
end

return LevelingHandler
