local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local DataHandler = require(ServerStorage.Game.Systems:WaitForChild("DataHandler"))
local QuestHandler = require(ServerStorage.Game.Systems:WaitForChild("QuestHandler"))
local NotifHandler = require(ServerStorage.Game.Systems:WaitForChild("NotifHandler"))
local SoundHandler = require(ServerStorage.Game.Systems:WaitForChild("SoundHandler"))

local RarityLabels = require(ReplicatedStorage.Data.Animals:WaitForChild("RarityLabels")).Animals
local XPGiven = require(ServerStorage.Data.Spawns:WaitForChild("XPGiven"))

local CollectionModule = {}

local function SplitByComma(str)
	local result = {}

	if not str or str == "" then
		return result
	end

	for value in string.gmatch(str, "[^,]+") do
		table.insert(result, value)
	end

	return result
end

function CollectionModule.SetupPrompt(area, animal, animal_name, weight, exclusiveToPlayer: Player)
	local pPart = animal.PrimaryPart or animal:FindFirstChild("PrimaryPart")
	if not pPart then
		warn("[Collection] Missing PrimaryPart for", animal_name)
		return
	end
	
	local mutations = animal:GetAttribute("Mutations")

	local prox = pPart:FindFirstChildOfClass("ProximityPrompt") or Instance.new("ProximityPrompt")
	prox.Parent = pPart
	prox.ActionText = ("%s kg"):format(tostring(weight))
	
	if mutations and mutations~='Default' then
		prox.ObjectText = animal_name .. " [" .. mutations .. "]"
	else
		prox.ObjectText = animal_name
	end
	
	prox.HoldDuration = 3
	prox.RequiresLineOfSight = false
	prox.MaxActivationDistance = 10
	prox.Enabled = true
	
	local activeSounds = {}

	local function stopSound(player)
		local id = activeSounds[player]
		if id then
			SoundHandler.StopClientSound(player, id)
			activeSounds[player] = nil
		end
	end

	prox.PromptButtonHoldBegan:Connect(function(player)
		local soundId = SoundHandler.PlayClientSound(
			player,
			ReplicatedStorage.Assets.SFX.Game["Foliage Crunchy Rustle 10 (SFX)"],
			prox.HoldDuration
		)
		activeSounds[player] = soundId
	end)

	prox.PromptButtonHoldEnded:Connect(function(player)
		stopSound(player)
	end)

	prox.Destroying:Connect(function()
		for player, _ in pairs(activeSounds) do
			stopSound(player)
		end
	end)
	

	prox.Triggered:Connect(function(player)
		if exclusiveToPlayer then
			if exclusiveToPlayer == player then
				CollectionModule.CollectAnimal(area, player, animal_name, animal)
			else
				NotifHandler.SendCustomNotif(player, "You can't collect this animal!", Color3.new(0.741176, 0, 0.0117647), 2, ReplicatedStorage.Assets.SFX.UI.Error)
			end
		else
			CollectionModule.CollectAnimal(area, player, animal_name, animal)
		end
	end)
end

function CollectionModule.CollectAnimal(area, player, animal_name, animal)
	local animalName = animal_name
	local data = DataHandler.GetData(player)

	if not data then
		warn("[Collection] No data for", player.Name)
		return
	end

	data.Backpack = data.Backpack or {}
	local weight = animal:GetAttribute("Weight")
	if not weight then
		warn("[Collection] Animal has no weight attribute:", animalName)
		return
	end
	
	local weightCanHandle = data.PlayerInfo.Strength
	if weightCanHandle < weight then
		NotifHandler.SendInsufficientStrenghtNotif(player)
		return
	end
	
	local mutations = animal:GetAttribute("Mutations")
	if not mutations then
		warn("[Collection] Animal has no mutations attribute:", animalName)
		return
	end
	mutations = SplitByComma(mutations)
	
	local favourite = false
	if table.find(RarityLabels.Legendary, animal_name) or table.find(RarityLabels.Mythic, animal_name) or table.find(RarityLabels.Exotic, animal_name) or table.find(RarityLabels.Limited, animal_name) then
		favourite = true
	end
	
	local animal_data = {
		Id = HttpService:GenerateGUID(false),
		Weight = weight,
		Mutations = mutations,
		
		Favourite = favourite
	}
	
	if data.Backpack[animalName] then
		table.insert(data.Backpack[animalName], animal_data)
	else
		data.Backpack[animalName] = {animal_data}
	end
	
	local xp = XPGiven.Xp[animalName].BaseXp
	local newPlayerXp = data.Stats.XP + xp
	
	if not data.MiscInfo.AnimalsCollected and typeof(data.MiscInfo.AnimalsCollected) ~= "table" then
		data.MiscInfo.AnimalsCollected = {}
	end
	
	table.insert(data.MiscInfo.AnimalsCollected, animalName)
	
	DataHandler.SetData(player, data)
	DataHandler.SetStat(player, "XP", newPlayerXp)
	
	QuestHandler.AddProgress(player,"Collect","Animal",1)
	
	SoundHandler.PlayClientSound(player, ReplicatedStorage.Assets.SFX.Game["Black Souls grass walk sound effect"])
	--print(("[Collection] %s collected %s (%skg)"):format(player.Name, animalName, weight))

	animal:Destroy()
end


return CollectionModule
