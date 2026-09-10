local ServerStorage = game:GetService('ServerStorage')
local Weights = require(ServerStorage.Data.Spawns:WaitForChild("Weights"))

local WeightsHelper = {}

local function roundToDP(num, dp)
	local mult = 10 ^ dp
	return math.floor(num * mult + 0.5) / mult
end

local function GetRandomWeight(low, high, rarityFactor)
	local t = math.random()
	t = t ^ rarityFactor
	return roundToDP(low + (high - low) * t, 2)
end

function WeightsHelper.RandomAnimalWeight(animal)
	local data = Weights[animal]
	if not data then
		warn("[WeightsHelper] Invalid animal:", animal)
	return end

	local weight = GetRandomWeight(data.Low, data.High, data.RarityFactor)
	
	return weight
end

return WeightsHelper
