local UpgradeHandler = {}

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes:WaitForChild("UpgradeEvents")

local DataHandler = require(ServerStorage.Game.Systems:WaitForChild("DataHandler"))

local UpgradeInfo = require(ReplicatedStorage.Data.Upgrades:WaitForChild("UpgradeInfo"))

function UpgradeHandler.GetUpgradePrice(upgradeName, level)
	return UpgradeInfo[upgradeName].Price(level)
end

function UpgradeHandler.Upgrade(player, upgradeName)
	local data = DataHandler.GetData(player)
	local oldCoins = data.Stats.Coins
	
	if not data.Upgrades[upgradeName] then
		data.Upgrades[upgradeName] = 0
	end
	
	local nextLevel = data.Upgrades[upgradeName] + 1
	local price = UpgradeHandler.GetUpgradePrice(upgradeName, nextLevel)
	
	if oldCoins < price then return 'CoinsRequirement' end
	if nextLevel > UpgradeInfo[upgradeName].MaxLevel then return 'MaxLevel' end
	
	if oldCoins >= price and nextLevel <= UpgradeInfo[upgradeName].MaxLevel then
		local newCoins = oldCoins - price
		data.Upgrades[upgradeName] = nextLevel
		DataHandler.SetData(player, data)
		UpgradeInfo[upgradeName].Apply(player, nextLevel)
		
		DataHandler.SetStat(player, "Coins", newCoins)
		return true
	end
	return false
end

local function EventsInit()
	UpgradeHandler.RequestUpgradeFunction = Instance.new('RemoteFunction')
	UpgradeHandler.RequestUpgradeFunction.Name = 'RequestUpgrade'
	UpgradeHandler.RequestUpgradeFunction.Parent = Remotes
	
	UpgradeHandler.RequestUpgradeFunction.OnServerInvoke = function(player, upgradeName)
		return UpgradeHandler.Upgrade(player, upgradeName)
	end
end

local function GetDataAndUpgradeAll(player)
	local attempt = 1
	local data
	
	repeat
		data = DataHandler.GetData(player)
		if not data then
			task.wait(1)
		end
		attempt += 1
	until data or attempt >=5

	for upgrade, info in pairs(UpgradeInfo) do
		local level = data.Upgrades[upgrade] or 0
		if level == 0 then
			data.Upgrades[upgrade] = 0
			DataHandler.SetData(player, data)
		end
		
		info.Apply(player, level)
	end
end

function UpgradeHandler.Init()
	EventsInit()	
	for _, player in Players:GetPlayers() do
		GetDataAndUpgradeAll(player)
	end
	
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			GetDataAndUpgradeAll(player)
		end)
	end)
	
	print('[UpgradeHandler] Initialised')
end

return UpgradeHandler