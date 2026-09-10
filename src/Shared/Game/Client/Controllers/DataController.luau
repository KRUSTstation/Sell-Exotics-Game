local DataController = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotifController = require(ReplicatedStorage.Game.Client.Controllers.UIController:WaitForChild("NotifController"))

local DataEvents = ReplicatedStorage.Remotes:WaitForChild("DataEvents")

local ChangeInStatUpdate = DataEvents:WaitForChild("ChangeInStatUpdate")

ChangeInStatUpdate.OnClientEvent:Connect(function(statType, amount)
	if statType == "Coins" then
		NotifController.CoinsChangedNotif(amount)
	end
end)

function DataController.GetStat(statType)
	local GetStatEvent = DataEvents:WaitForChild("GetStat")
	return GetStatEvent:InvokeServer(statType)
end

function DataController.GetUpgradeLevel(upgradeName)
	local GetUpgradeLevelEvent = DataEvents:WaitForChild("GetUpgradeLevel")
	return GetUpgradeLevelEvent:InvokeServer(upgradeName)
end

function DataController.GetAnimalInv()
	local GetAnimalInvEvent = DataEvents:WaitForChild("GetAnimalInv")
	return GetAnimalInvEvent:InvokeServer()
end

function DataController.SetAnimalFav(animalName: string, index: number, favourite: boolean)
	local SetAnimalFavEvent = DataEvents:WaitForChild("SetAnimalFav")
	return SetAnimalFavEvent:FireServer(animalName, index, favourite)
end

return DataController