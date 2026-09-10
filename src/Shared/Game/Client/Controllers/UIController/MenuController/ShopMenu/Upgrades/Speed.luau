local Speed = {}
Speed.__index = Speed

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = ReplicatedStorage.Game.Client:WaitForChild("Services")

local FormatNumbers = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("FormatNumbers"))
local DataController = require(ReplicatedStorage.Game.Client.Controllers:WaitForChild("DataController"))
local UpgradeInfo = require(ReplicatedStorage.Data.Upgrades:WaitForChild("UpgradeInfo"))
local NotifController = require(ReplicatedStorage.Game.Client.Controllers.UIController:WaitForChild("NotifController"))

local RequestUpgradeFunction = ReplicatedStorage.Remotes.UpgradeEvents:WaitForChild("RequestUpgrade")

local UIController

local onClickConn
local cd = false

function Speed.Update()
	local speed = DataController.GetUpgradeLevel("Speed")
	if speed >= UpgradeInfo.Strength.MaxLevel then
		Speed.LevelLabel.Text = "Max Level"
		Speed.PriceLabel.Text = ""
	else
		Speed.LevelLabel.Text = tostring(speed) .. '/' .. tostring(UpgradeInfo.Speed.MaxLevel)
		Speed.PriceLabel.Text = tostring(FormatNumbers.formatBigNumber(UpgradeInfo.Speed.Price(speed + 1))) .. ' Coins'
	end
end

function Speed.Init(uiController)
	if not uiController then return end

	UIController = uiController

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local frame = gameUI:WaitForChild("Shop"):WaitForChild("Frame"):WaitForChild("Tabs"):WaitForChild("Upgrades"):WaitForChild("Grid"):WaitForChild("Speed")
	
	local levelLabel = frame:WaitForChild("Level")
	local titleLabel = frame:WaitForChild("Title")
	local priceLabel = frame:WaitForChild("Price")
	local button = frame:WaitForChild("Button")

	Speed.Frame = frame
	Speed.Button = button
	Speed.LevelLabel = levelLabel
	Speed.TitleLabel = titleLabel
	Speed.PriceLabel = priceLabel

	if onClickConn then onClickConn:Disconnect() end
	
	Speed.Update()
	onClickConn = Speed.Button.MouseButton1Click:Connect(function()
		if cd then return end
		cd = true
		
		local passed = RequestUpgradeFunction:InvokeServer("Speed")
		if passed ~= true then
			if passed == "CoinsRequirement" then
				NotifController.NoMoneyNotif()
			elseif passed == "MaxLevel" then
				NotifController.MaxLevelNotif()
			end
		else
			Speed.Update()
		end
		cd = false
	end)

	print("[Speed] Initialised")
end

return Speed