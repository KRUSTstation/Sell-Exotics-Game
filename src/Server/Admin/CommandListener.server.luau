local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Spawning = require(ServerStorage.Game.Systems:WaitForChild("Spawning"))
local DataHandler = require(ServerStorage.Game.Systems:WaitForChild("DataHandler"))
local UpgradeHandler = require(ServerStorage.Game.Systems:WaitForChild("ShopHandler"):WaitForChild("UpgradeHandler"))
local IslandTravelHandler = require(ServerStorage.Game.Systems:WaitForChild("IslandTravelHandler"))

local ADMINS = {
	[3100921960] = true,
	[1257815111] = true,
	[504072574] = true,
	[184143966] = true,
}

local PREFIX = "/"

local function isAdmin(player)
	return ADMINS[player.UserId] == true
end

local function runCommand(player, message)
	if not isAdmin(player) then return end

	if string.sub(message, 1, #PREFIX) ~= PREFIX then return end

	local args = string.split(message, " ")
	local command = string.lower(string.sub(args[1], #PREFIX + 1))

	if command == "kick" then
		local targetName = args[2]

		for _, plr in pairs(Players:GetPlayers()) do
			if string.lower(plr.Name) == string.lower(targetName) then
				plr:Kick("Kicked by admin")
			end
		end

	elseif command == "speed" then
		local speed = tonumber(args[2])
		if speed and player.Character then
			player.Character.Humanoid.WalkSpeed = speed
		end
		
	elseif command == "spawnanimal" then
		local area = args[2]
		local animal = args[3]
		local count = tonumber(args[4]) or 1
		
		local spawnArea = ServerStorage.SpawnAreas:FindFirstChild(area)

		local animalMesh = ReplicatedStorage.Assets.Meshes.Animals:FindFirstChild(animal)

		if not spawnArea then
			warn(("[Spawning] %s area not found"):format(area))
		elseif not animalMesh then
			warn(("[Spawning] %s animal mesh not found"):format(animal))
		else
			Spawning.SpawnInArea(spawnArea, animalMesh, count)
		end
	
	elseif command == "givestat" then
		local player = Players:FindFirstChild(args[2])
		local stat = args[3]
		local amount = tonumber(args[4])
		
		if stat == "Level" or stat == "MaxXP" then
			warn("Cannot change stat")
			return
		end
		
		local data = DataHandler.GetData(player)
		if not data then return end
		
		DataHandler.SetStat(player, stat, data.Stats[stat] + amount)
	elseif command == "upgradeplayer" then
		local player = Players:FindFirstChild(args[2])
		local stat = args[3]
		local amount = tonumber(args[4]) or 1
		
		for i = 1,amount do
			UpgradeHandler.Upgrade(player, stat)
		end
	elseif command == "tptoisland" then
		local player = Players:FindFirstChild(args[2])
		local island = args[3]
		
		IslandTravelHandler.GoTo(player, island, true)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		runCommand(player, message)
	end)
end)