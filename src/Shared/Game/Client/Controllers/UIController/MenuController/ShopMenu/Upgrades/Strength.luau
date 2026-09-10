local Strength = {}
Strength.__index = Strength

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

function Strength.Update()
	local strength = DataController.GetUpgradeLevel("Strength")
	if strength >= UpgradeInfo.Strength.MaxLevel then
		Strength.LevelLabel.Text = "Max Level"
		Strength.PriceLabel.Text = ""
	else
		Strength.LevelLabel.Text = tostring(strength) .. '/' .. tostring(UpgradeInfo.Strength.MaxLevel)
		Strength.PriceLabel.Text = tostring(FormatNumbers.formatBigNumber(UpgradeInfo.Strength.Price(strength + 1))) .. ' Coins'
	end
end

function Strength.Init(uiController)
	if not uiController then return end

	UIController = uiController

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local frame = gameUI:WaitForChild("Shop"):WaitForChild("Frame"):WaitForChild("Tabs"):WaitForChild("Upgrades"):WaitForChild("Grid"):WaitForChild("Strength")
	
	local levelLabel = frame:WaitForChild("Level")
	local titleLabel = frame:WaitForChild("Title")
	local priceLabel = frame:WaitForChild("Price")
	local button = frame:WaitForChild("Button")

	Strength.Frame = frame
	Strength.Button = button
	Strength.LevelLabel = levelLabel
	Strength.TitleLabel = titleLabel
	Strength.PriceLabel = priceLabel

	if onClickConn then onClickConn:Disconnect() end
	
	Strength.Update()
	onClickConn = Strength.Button.MouseButton1Click:Connect(function()
		if cd then return end
		cd = true
		
		local passed = RequestUpgradeFunction:InvokeServer("Strength")
		if passed ~= true then
			if passed == "CoinsRequirement" then
				NotifController.NoMoneyNotif()
			elseif passed == "MaxLevel" then
				NotifController.MaxLevelNotif()
			end
		else
			Strength.Update()
		end
		cd = false
	end)

	print("[Strength] Initialised")
end

return Strength