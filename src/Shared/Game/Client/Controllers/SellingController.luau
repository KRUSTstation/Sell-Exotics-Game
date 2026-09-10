local SellingController = {}

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SellingEvents = ReplicatedStorage.Remotes:WaitForChild("SellingEvents")

function SellingController.GetTotalPrice()
	local GetTotalPriceEvent = SellingEvents:WaitForChild("GetTotalPrice")
	return GetTotalPriceEvent:InvokeServer(player)
end

return SellingController