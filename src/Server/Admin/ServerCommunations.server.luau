local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local TOPIC = "ShutdownForUpdate"

local function shutdownServer()
	for _, player in ipairs(Players:GetPlayers()) do
		player:Kick("Server restarting for update. Please rejoin!")
	end
end

MessagingService:SubscribeAsync(TOPIC, function(message)
	print("Shutdown message received:", message.Data)
	shutdownServer()
end)

--[[
To shutdown,
Call:
	local MessagingService = game:GetService("MessagingService")
	MessagingService:PublishAsync("ShutdownForUpdate", "restart")


]]