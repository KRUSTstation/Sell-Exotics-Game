local StatController = {}

local StatController = {}
StatController.__index = StatController

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes

local FormatNumbers = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("FormatNumbers"))

local DataController = require(ReplicatedStorage.Game.Client.Controllers:WaitForChild("DataController"))

local statUpdatedEvent = Remotes:WaitForChild("DataEvents"):WaitForChild("StatUpdated")
local getStatEvent = Remotes:WaitForChild("DataEvents"):WaitForChild("GetStat")

function StatController.updateXPBar(XP)
	local maxXP = DataController.GetStat("MaxXP")
	local percent = XP / maxXP
	
	local bar = StatController.StatFolder.XP.Fill
	local gradient = bar.UIGradient
	local value = StatController.StatFolder.XP:FindFirstChild("Value")
	
	value.Text = FormatNumbers.formatBigNumber(XP) .. "/" .. FormatNumbers.formatBigNumber(maxXP)

	gradient.Offset = Vector2.new(-1 + percent, 0)
end

function StatController.Update(stat, value)
	if stat == "MaxXP" then return end
	
	if stat == "XP" then
		StatController.updateXPBar(value)
		return
	end
	
	local statFrame = StatController.StatFolder:FindFirstChild(stat, true)
	
	if not stat then
		warn("Stat not found: " .. stat)
		return
	end
	
	value = FormatNumbers.formatBigNumber(value)
	statFrame.Amount.TextLabel.Text = value
end

function StatController.Init()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local mainUi = gameUI:WaitForChild("Main")

	local frame = mainUi:WaitForChild("Frame")
	local statFolder = frame:WaitForChild("Stats")

	StatController.MainUI = mainUi
	StatController.Frame = frame
	StatController.StatFolder = statFolder
	
	for _, stat in pairs(statFolder:GetDescendants()) do
		if not stat:IsA("Frame") then continue end
		
		local statName = stat.Name
		local statValue = getStatEvent:InvokeServer(statName)
		StatController.Update(statName, statValue)
	end
	
	statUpdatedEvent.OnClientEvent:Connect(StatController.Update)
	
	--if statUpdateThread then
	--	task.cancel(statUpdateThread)
	--end
	
	--statUpdateThread = task.spawn(function()
	--	while true do
	--		StatController.populate()
	--		task.wait(0.5)
	--	end
	--end)

	print("[StatController] StatController initialised")
end



return StatController
