local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")

local Sells = require(ServerStorage.Data:WaitForChild("Sells"))
local Weights = require(ServerStorage.Data.Spawns:WaitForChild("Weights"))
local MutationInfo = require(ServerStorage.Data.Spawns.Mutations:WaitForChild("MutationInfo"))

local StormChance = 100 -- Higher is rarer

local SellingHelper = {}
local DataHandler
local PlayShipCutsceneEvent

local function ifStorm()
	return math.random(1, StormChance) == 1
end

function SellingHelper.CalculatePriceByWeight(animal, weight)
	local sellData = Sells[animal]
	local weightData = Weights[animal]
	if not sellData or not weightData then
		return nil
	end

	local lowWeight = weightData.Low
	local highWeight = weightData.High
	local midWeight = (lowWeight + highWeight) / 2

	local midPrice = sellData.MidPrice
	local variation = sellData.Variation
	local steepness = sellData.Steepness or 1

	local normalized = (weight - midWeight) / (highWeight - midWeight)
	normalized = math.clamp(normalized, -1, 1)

	local expS = math.exp(steepness)
	local expNegS = math.exp(-steepness)

	local shaped =
		(math.exp(steepness * normalized) - math.exp(-steepness * normalized))
		/ (expS - expNegS)

	local multiplier = 1 + variation * shaped
	local price = midPrice * multiplier

	return math.round(price * 100) / 100
end

function SellingHelper.CalculatePriceByMutations(mutations, currPrice)
	local totalMultiplier = 1
	
	for _, mutation in pairs(mutations) do
		local multiplier = MutationInfo.Mutations[mutation].Multiplier
		totalMultiplier *= multiplier
	end
	
	local newPrice = currPrice * totalMultiplier
	return newPrice
end

function SellingHelper.GetPrice(animal, animal_data)
	local weight = animal_data.Weight
	local mutations = animal_data.Mutations
	local price = SellingHelper.CalculatePriceByWeight(animal, weight)
	
	price = SellingHelper.CalculatePriceByMutations(mutations, price)
	return price
end

function SellingHelper.GetTotalPrice(player: Player)
	local data = DataHandler.GetData(player)
	local totalCost = 0

	if not next(data.Backpack) then
		return
	end
	
	local animalsToSell = {}
	for animal, infos in pairs(data.Backpack) do
		animalsToSell[animal] = {}
		for i, animal_data in ipairs(infos) do
			if animal_data.Favourite then continue end
			table.insert(animalsToSell[animal], {index = i, data = animal_data})
		end
	end
	
	for animal, items in pairs(animalsToSell) do
		for i = #items, 1, -1 do
			local entry = items[i]
			local animal_data = entry.data
			
			local price = SellingHelper.GetPrice(animal, animal_data)
			totalCost += price
		end
	end
	
	if math.abs(totalCost) < 1e-6 then -- floating point error lol
		return nil
	end

	return totalCost
end

function SellingHelper.SellItems(player: Player)
	local data = DataHandler.GetData(player)
	
	if not next(data.Backpack) then
		print(("[SellingHelper] %s has no animals to sell"):format(player.Name))
		return
	end

	local storm = ifStorm()

	local animalsToSell = {}
	for animal, infos in pairs(data.Backpack) do
		animalsToSell[animal] = {}
		for i, animal_data in ipairs(infos) do
			if animal_data.Favourite then continue end
			table.insert(animalsToSell[animal], {index = i, data = animal_data})
		end
	end

	local finished = PlayShipCutsceneEvent:InvokeClient(player, storm)
	if not finished then
		return
	end

	for animal, items in pairs(animalsToSell) do
		for i = #items, 1, -1 do
			local entry = items[i]
			local animal_data = entry.data
			local index = entry.index
			
			if not storm then
				local price = SellingHelper.GetPrice(animal, animal_data)
				data.Stats.Coins += price
			end
			table.remove(data.Backpack[animal], index)
		end

		if #data.Backpack[animal] == 0 then
			data.Backpack[animal] = nil
		end
		
		DataHandler.SetStat(player, "Coins", data.Stats.Coins)
	end

	if storm then
		print(("[SellingHelper] %s's animals were lost due to the storm!"):format(player.Name))
	end

	DataHandler.SetData(player, data)
end

local function EventsInit()
	PlayShipCutsceneEvent = Instance.new("RemoteFunction")
	PlayShipCutsceneEvent.Name = "PlayShipCutsceneFunction"
	PlayShipCutsceneEvent.Parent = ReplicatedStorage.Remotes.SellingEvents.ShipEvents
	
	local GetTotalPriceFunction = Instance.new("RemoteFunction")
	GetTotalPriceFunction.Name = "GetTotalPrice"
	GetTotalPriceFunction.Parent = ReplicatedStorage.Remotes.SellingEvents
	GetTotalPriceFunction.OnServerInvoke = SellingHelper.GetTotalPrice
end

local function SellingPromptInit()
	local sellNPC = workspace.SpawnArea.Ship:WaitForChild("Sell")
	local proxPrompt = sellNPC:WaitForChild("ProximityPrompt")

	proxPrompt.Triggered:Connect(SellingHelper.SellItems)
end

function SellingHelper.Init()
	DataHandler = require(ServerStorage.Game.Systems:WaitForChild("DataHandler"))
	
	local ShipHandler = require(script:WaitForChild("ShipHandler"))
	ShipHandler.Init()
	
	EventsInit()
	
	SellingPromptInit()
	
	print("[SellingHelper] Selling initialization complete.")
end

return SellingHelper
