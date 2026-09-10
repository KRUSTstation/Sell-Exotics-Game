local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes
local WayStoneUpdatedEvent = Remotes.DataEvents:WaitForChild("WayStoneUpdated")

local WayStoneController = {}

function WayStoneController.UpdateWayStone(newWayStone, oldWayStone)
	local oldWaystoneModel = workspace.Waystones:FindFirstChild(oldWayStone)
	local newWaystoneModel = workspace.Waystones:FindFirstChild(newWayStone)

	if oldWaystoneModel and oldWayStone ~= newWayStone then
		for _, part in pairs(oldWaystoneModel.Waystone:GetChildren()) do
			if part.Name == "Neon" then
				part.Color = Color3.fromRGB(255, 0, 0)
			end
		end
	end

	for _, part in pairs(newWaystoneModel.Waystone:GetChildren()) do
		if part.Name == "Neon" then
			part.Color = Color3.fromRGB(0, 255, 0)
		end
	end
end

function WayStoneController.Init()
	WayStoneUpdatedEvent.OnClientEvent:Connect(WayStoneController.UpdateWayStone)
end

return WayStoneController
