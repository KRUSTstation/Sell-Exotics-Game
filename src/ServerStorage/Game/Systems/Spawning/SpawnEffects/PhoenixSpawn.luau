local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local EffectHandler = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("EffectHandler"))
local SystemMessageHandler = require(ServerStorage.Game.Systems:WaitForChild("SystemMessageHandler"))

local SFX = ReplicatedStorage.Assets.SFX.Game

local PhoenixSpawn = {}

function PhoenixSpawn.Attach(model)
	EffectHandler.PlayEffect('PhoenixSpawn', model)
	local Phoenix1 = SFX:WaitForChild("Phoenix1"):Clone()
	local Phoenix2 = SFX:WaitForChild("Phoenix2"):Clone()
	
	Phoenix1.Parent = model
	Phoenix2.Parent = model
	
	Phoenix1:Play()
	Phoenix2:Play()	
	
	SystemMessageHandler.SendGlobalMessage("Flames dance… something watches", Color3.fromRGB(255, 255, 0), Enum.Font.FredokaOne)
end

return PhoenixSpawn
