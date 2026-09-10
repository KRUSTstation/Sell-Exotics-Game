local PlayerInfoController = {}

local PlayerInfoController = {}
PlayerInfoController.__index = PlayerInfoController

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes

local FormatNumbers = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("FormatNumbers"))

local DataController = require(ReplicatedStorage.Game.Client.Controllers:WaitForChild("DataController"))

local PlayerInfoUpdatedEvent = Remotes:WaitForChild("DataEvents"):WaitForChild("PlayerInfoUpdated")
local GetPlayerInfoEvent = Remotes:WaitForChild("DataEvents"):WaitForChild("GetPlayerInfo")

function PlayerInfoController.Update(stat, value)
	local statText = PlayerInfoController.StatFrame:FindFirstChild(stat, true)

	if not statText then
		warn("Stat not found: " .. stat)
		return
	end
	if not statText:IsA("TextLabel") then return end

	value = FormatNumbers.formatBigNumber(value)
	if stat == "Speed" then
		value = "Speed: " .. tostring(value) .. " studs/s"
	elseif stat == "Strength" then
		value = "Strength: " .. tostring(value) .. " kg"
	end
	
	statText.Text = value
end

function PlayerInfoController.Init()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local mainUi = gameUI:WaitForChild("Main")

	local frame = mainUi:WaitForChild("Frame")
	local statFolder = frame:WaitForChild("PlayerInfo")

	PlayerInfoController.MainUI = mainUi
	PlayerInfoController.Frame = frame
	PlayerInfoController.StatFrame = statFolder:WaitForChild("Frame")

	for _, stat in pairs(PlayerInfoController.StatFrame:GetDescendants()) do
		if not stat:IsA("TextLabel") then continue end

		local statName = stat.Name
		local statValue = GetPlayerInfoEvent:InvokeServer(statName)
		PlayerInfoController.Update(statName, statValue)
	end

	PlayerInfoUpdatedEvent.OnClientEvent:Connect(PlayerInfoController.Update)

	--if statUpdateThread then
	--	task.cancel(statUpdateThread)
	--end

	--statUpdateThread = task.spawn(function()
	--	while true do
	--		PlayerInfoController.populate()
	--		task.wait(0.5)
	--	end
	--end)

	print("[PlayerInfoController] PlayerInfoController initialised")
end



return PlayerInfoController
