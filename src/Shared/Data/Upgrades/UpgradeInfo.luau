local StarterPlayer = game:GetService("StarterPlayer")
local RunService = game:GetService("RunService")

local UpgradeInfo = {}

-- When adding new upgrade, make sure to change datahandler defaults as well

UpgradeInfo.Speed = {
	MaxLevel = 35,
	
	Price = function(level) return level*100 end,
	Quantity = function(level) return StarterPlayer.CharacterWalkSpeed + level end,
	Apply = function(player, level)
		if RunService:IsClient() then return end
		
		local DataHandler = require(game.ServerStorage.Game.Systems.DataHandler)
		DataHandler.SetPlayerInfo(player, "Speed", UpgradeInfo.Speed.Quantity(level))
		
		player.Character.Humanoid.WalkSpeed = UpgradeInfo.Speed.Quantity(level)
	end	
}

UpgradeInfo.Strength = {
	MaxLevel = 200,
	
	Price = function(level) if level <= 20 then return (75 + (level - 1) * 25) else return (75 + (level - 1) * 50) end end,
	Quantity = function(level) return 5 + level * 5 end,
	Apply = function(player, level)
		if RunService:IsClient() then return end
		
		local DataHandler = require(game.ServerStorage.Game.Systems.DataHandler)
		DataHandler.SetPlayerInfo(player, "Strength", UpgradeInfo.Strength.Quantity(level))
	end
}

return UpgradeInfo