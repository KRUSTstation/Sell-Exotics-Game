local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local DataHandler = require(ServerStorage.Game.Systems:WaitForChild("DataHandler"))

local url = "https://6da9-129-126-35-211.ngrok-free.app/roblox/player-update"

while true do
	for _, player in pairs(Players:GetPlayers()) do
		local data = DataHandler.GetData(player)
		if not data then continue end
		
		local dataToSend = {
			Username = player.Name,
			UserId = player.UserId,

			Coins = data.Stats.Coins,
			Level = data.Stats.Level,
			MaxXp = data.Stats.MaxXP,
			Xp = data.Stats.XP,

			AnimalsCollected = data.MiscInfo.AnimalsCollected
		}

		local jsonData = HttpService:JSONEncode(dataToSend)

		local response = HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Authentication"] = "LKSAdud82i!@#d"
			},
			Body = jsonData
		})
		
		print(response.StatusCode, response.Body)
	end
	
	task.wait(10)
end