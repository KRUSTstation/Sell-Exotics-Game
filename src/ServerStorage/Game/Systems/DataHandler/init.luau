local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LevelingHandler = require(script:WaitForChild("LevelingHandler"))
local TutorialHandler = require(script:WaitForChild("TutorialHandler"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataEvents = ReplicatedStorage.Remotes:WaitForChild("DataEvents")
local DataBindables = ReplicatedStorage.Bindables:WaitForChild("DataEvents")

local UpgradeInfo = require(ReplicatedStorage.Data.Upgrades:WaitForChild("UpgradeInfo"))

local DataHandler = {}
local sessionData = {}

local StatUpdatedEvent
local ChangeInStatUpdateEvent
local AnimalInvUpdatedEvent
local WayStoneUpdatedEvent
local PlayerInfoUpdatedEvent

--[[
Datastore naming convention:

XYa.b.c

X: Major Version
Y: Type
a: Major Data Reset
b: Major Bug Fixes
c: Minor Bug Fixes
]]

local DataStore = DataStoreService:GetDataStore(
	RunService:IsStudio() and "dataStudio6" or "AlphaGame1.0.2" 
)

local DefaultData = {
	Stats = {
		Coins = 0,
		Level = 1,
		XP = 0,
		MaxXP = LevelingHandler.GetMaxXp(1),
	},
	PlayerInfo = {
		Strength = UpgradeInfo.Strength.Quantity(1),
		Speed = UpgradeInfo.Speed.Quantity(1),
	},
	Upgrades = {},
	Backpack = {},
	Tool_Inventory = {},
	WayStoneLocation = nil,
	Storage = {},
	TutorialStages = {},
	Quests = {},
	MiscInfo = {
		AnimalsCollected = {}
	},
	Settings = {
		-- sound
		Music = 1,
		SFX = 1,
		
		-- game
		AutoFavourite = true,
		
		-- ui
		DisableViewPorts = false,
	},
}

local InLeaderStats = {
	Coins = true,
	Level = true
}

local ResetOnJoin = {
}

local ResetOnDeath = {
}

local OrderedLeaderstats = {"Level", "Coins"}

local function DeepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		if typeof(v) == "table" then
			copy[k] = DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function ApplyResets(data, defaults, rules)
	for k, rule in pairs(rules) do
		if rule == true then
			data[k] = DeepCopy(defaults[k])
		elseif typeof(rule) == "table" and typeof(data[k]) == "table" then
			for subKey, shouldReset in pairs(rule) do
				if shouldReset == true then
					data[k][subKey] = defaults[k][subKey]
				end
			end
		end
	end
end

local function ValidateAndMigrateData(data, defaults)
	for key, defaultValue in pairs(defaults) do
		local currentValue = data[key]

		if currentValue == nil then
			if typeof(defaultValue) == "table" then
				data[key] = DeepCopy(defaultValue)
			else
				data[key] = defaultValue
			end

		elseif typeof(currentValue) ~= typeof(defaultValue) then
			warn(`[Datahandler] Type mismatch on "{key}", resetting`)
			if typeof(defaultValue) == "table" then
				data[key] = DeepCopy(defaultValue)
			else
				data[key] = defaultValue
			end

		elseif typeof(defaultValue) == "table" then
			ValidateAndMigrateData(currentValue, defaultValue)
		end
	end

	for key in pairs(data) do
		if defaults[key] == 'Deprecated' then
			warn(`[Datahandler] Removing deprecated key "{key}"`)
			data[key] = nil
		end
	end
end

local function LoadData(player)
	local success, data
	local attempt = 1

	repeat
		success, data = pcall(function()
			return DataStore:GetAsync(player.UserId)
		end)

		if not success then
			warn(`[Datahandler] Failed to load data for {player.Name}, retrying... ({attempt})`)
			task.wait(2)
		end
		attempt += 1
	until success or attempt > 5

	if not success then
		warn(`[Datahandler] Giving default data to {player.Name}`)
		data = DeepCopy(DefaultData)
	elseif not data then
		print(`[Datahandler] No existing data for {player.Name}, using defaults.`)
		data = DeepCopy(DefaultData)
	else
		ValidateAndMigrateData(data, DefaultData)
		ApplyResets(data, DefaultData, ResetOnJoin)
	end
	
	sessionData[player.UserId] = data
	return data
end

local function SaveData(player)
	local data = sessionData[player.UserId]
	if not data then return end

	local success, err
	local attempt = 1

	repeat
		success, err = pcall(function()
			DataStore:UpdateAsync(player.UserId, function()
				return data
			end)
		end)
		if not success then
			warn(`[Datahandler] Failed to save data for {player.Name}, retrying... ({attempt})`)
			task.wait(2)
		end
		attempt += 1
	until success or attempt > 5

	if success then
		print(`[Datahandler] Data saved for {player.Name}`)
	else
		warn(`[Datahandler] Could not save data for {player.Name}: {err}`)
	end
end

local function OnPlayerAdded(player)
	local data = LoadData(player)
	sessionData[player.UserId] = data
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	for _, statName in ipairs(OrderedLeaderstats) do
		if InLeaderStats[statName] then
			local value = data.Stats[statName]

			local val = Instance.new("NumberValue")
			val.Name = statName
			val.Value = value
			val.Parent = leaderstats

			val.Changed:Connect(function(newValue)
				data.Stats[statName] = newValue
			end)

			task.spawn(function()
				while player.Parent do
					if val.Value ~= data.Stats[statName] then
						val.Value = data.Stats[statName]
					end
					task.wait(0.1)
				end
			end)
		end
	end
	
	player.CharacterAdded:Connect(function(char)
		local hum = char:WaitForChild("Humanoid")
		hum.Died:Connect(function()
			local data = sessionData[player.UserId]
			if not data then
				return
			end
			
			ApplyResets(sessionData[player.UserId], DefaultData, ResetOnDeath)

			if player:FindFirstChild("leaderstats") then
				for statName, val in pairs(sessionData[player.UserId].Stats) do
					local statObj = player.leaderstats:FindFirstChild(statName)
					if statObj then
						statObj.Value = val
					end
				end
			end
		end)
	end)
end

local function OnPlayerRemoving(player)
	local data = sessionData[player.UserId]
	if not data then return end

	if player:FindFirstChild("leaderstats") then
		for _, stat in ipairs(player.leaderstats:GetChildren()) do
			data.Stats[stat.Name] = stat.Value
		end
	end

	SaveData(player)
	sessionData[player.UserId] = nil
end

local function OnServerShutdown()
	print("[Datahandler] Server shutting down, saving all data...")
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			OnPlayerRemoving(player)
		end)
	end
end

function DataHandler.GetData(player)
	local data = sessionData[player.UserId]
	if not data then
		return nil
	end
	return DeepCopy(data)
end

function DataHandler.SetData(player, newData)
	sessionData[player.UserId] = newData
end

local function CheckDataValidity(player)
	local data = DataHandler.GetData(player)
	if not data then
		-- warn("No session data for", player.Name)
		return DefaultData
	else
		return data
	end
end

-- ============== ALL EVENTS HERE ===============
function DataHandler.SetStat(player, statName, value)
	local data = sessionData[player.UserId]
	if not data then return end
	
	if typeof(value) == "number" then
		--value = math.floor(value * 100 + 0.5) / 100
		value = math.floor(value + 0.5)
	end
	
	local initialValue = data.Stats[statName]
	local change = value - initialValue	
	
	data.Stats[statName] = value
	
	if statName == 'XP' then
		local success = LevelingHandler.AttemptLevelUp(player)
		if success then return end
	end

	if player:FindFirstChild("leaderstats") then
		local statObj = player.leaderstats:FindFirstChild(statName)
		if statObj then
			statObj.Value = value
		end
	end
	
	ChangeInStatUpdateEvent:FireClient(player, statName, change)
	StatUpdatedEvent:FireClient(player, statName, value)
end

function DataHandler.SetPlayerInfo(player, statName, value)
	local data = sessionData[player.UserId]
	if not data then return end

	if typeof(value) == "number" then
		--value = math.floor(value * 100 + 0.5) / 100
		value = math.floor(value + 0.5)
	end

	local initialValue = data.PlayerInfo[statName]
	local change = value - initialValue	

	data.PlayerInfo[statName] = value

	PlayerInfoUpdatedEvent:FireClient(player, statName, value)
end

function DataHandler.SetAnimalInv(player, value)
	local data = sessionData[player.UserId]
	if not data then return end

	data.Backpack = value

	AnimalInvUpdatedEvent:FireClient(player, value)
end

function DataHandler.SetWayStone(player, waystone)
	local data = sessionData[player.UserId]
	if not data then return end
	
	local oldWayStone = data.WayStoneLocation

	data.WayStoneLocation = waystone
	WayStoneUpdatedEvent:FireClient(player, waystone, oldWayStone)
end

local function GetStatEventFunc(player, statName)
	if typeof(statName) ~= "string" then
		warn(player.Name, "sent invalid currencyName:", statName)
		return nil
	end

	local data = CheckDataValidity(player)

	return data.Stats[statName] or 0
end

local function GetPlayerInfoEventFunc(player, statName)
	if typeof(statName) ~= "string" then
		warn(player.Name, "sent invalid name:", statName)
		return nil
	end

	local data = CheckDataValidity(player)

	return data.PlayerInfo[statName] or 0
end

local function GetUpgradeLevelEventFunc(player, upgradeName)
	local data = CheckDataValidity(player)
	if not data.Upgrades[upgradeName] then
		return 0
	end
	return data.Upgrades[upgradeName]
end

local function GetAnimalInvEventFunc(player)
	local data = CheckDataValidity(player)

	return data.Backpack
end

local function SetAnimalFavEventFunc(player, animalName, Id, favourite)
	local data = sessionData[player.UserId]
	if not data then return end
	
	local animals = data.Backpack[animalName]
	if not animals then return end
	
	for _, animal in ipairs(animals) do
		if animal.Id == Id then
			animal.Favourite = favourite
			break
		end
	end
end

local function EventsInit()
	StatUpdatedEvent = Instance.new("RemoteEvent")
	StatUpdatedEvent.Name = "StatUpdated"
	StatUpdatedEvent.Parent = DataEvents
	
	ChangeInStatUpdateEvent = Instance.new("RemoteEvent")
	ChangeInStatUpdateEvent.Name = "ChangeInStatUpdate"
	ChangeInStatUpdateEvent.Parent = DataEvents
	
	PlayerInfoUpdatedEvent = Instance.new("RemoteEvent")
	PlayerInfoUpdatedEvent.Name = "PlayerInfoUpdated"
	PlayerInfoUpdatedEvent.Parent = DataEvents
	
	local GetPlayerInfoEvent = Instance.new("RemoteFunction")
	GetPlayerInfoEvent.Name = "GetPlayerInfo"
	GetPlayerInfoEvent.Parent = DataEvents
	GetPlayerInfoEvent.OnServerInvoke = GetPlayerInfoEventFunc
	
	local GetStatEvent = Instance.new("RemoteFunction")
	GetStatEvent.Name = "GetStat"
	GetStatEvent.Parent = DataEvents
	GetStatEvent.OnServerInvoke = GetStatEventFunc
	
	--local StatUpdatedBindable = Instance.new("BindableEvent")
	--StatUpdatedBindable.Name = "StatUpdatedBindable"
	--StatUpdatedBindable.Parent = DataEvents
	
	AnimalInvUpdatedEvent = Instance.new("RemoteEvent")
	AnimalInvUpdatedEvent.Name = "AnimalInvUpdated"
	AnimalInvUpdatedEvent.Parent = DataEvents
	
	local GetAnimalInvEvent = Instance.new("RemoteFunction")
	GetAnimalInvEvent.Name = "GetAnimalInv"
	GetAnimalInvEvent.Parent = DataEvents
	GetAnimalInvEvent.OnServerInvoke = GetAnimalInvEventFunc
	
	WayStoneUpdatedEvent = Instance.new("RemoteEvent")
	WayStoneUpdatedEvent.Name = "WayStoneUpdated"
	WayStoneUpdatedEvent.Parent = DataEvents
	
	local SetAnimalFavEvent = Instance.new("RemoteEvent")
	SetAnimalFavEvent.Name = "SetAnimalFav"
	SetAnimalFavEvent.Parent = DataEvents
	SetAnimalFavEvent.OnServerEvent:Connect(SetAnimalFavEventFunc)
	
	local GetUpgradeLevelEvent = Instance.new("RemoteFunction")
	GetUpgradeLevelEvent.Name = "GetUpgradeLevel"
	GetUpgradeLevelEvent.Parent = DataEvents
	GetUpgradeLevelEvent.OnServerInvoke = GetUpgradeLevelEventFunc
	
	--local AnimalInvUpdatedBindable = Instance.new("BindableEvent")
	--AnimalInvUpdatedBindable.Name = "AnimalInvUpdated"
	--AnimalInvUpdatedBindable.Parent = DataEvents
end

function DataHandler.Init()
	Players.PlayerAdded:Connect(OnPlayerAdded)
	Players.PlayerRemoving:Connect(OnPlayerRemoving)
	game:BindToClose(OnServerShutdown)
	EventsInit()
	print("[Datahandler] DataHandler initialized")
	LevelingHandler.Init(DataHandler)
	TutorialHandler.Init(DataHandler)
	return
end

return DataHandler