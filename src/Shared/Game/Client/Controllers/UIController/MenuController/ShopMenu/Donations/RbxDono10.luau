local RbxDono10 = {}
RbxDono10.__index = RbxDono10

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = ReplicatedStorage.Game.Client:WaitForChild("Services")

local PurchaseService = require(Services:WaitForChild("PurchaseService"))

local UIController

local onClickConn

function RbxDono10.Init(uiController)
	if not uiController then return end

	UIController = uiController

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local frame = gameUI:WaitForChild("Shop"):WaitForChild("Frame"):WaitForChild("Tabs"):WaitForChild("Donations"):WaitForChild("Grid"):WaitForChild("RbxDono10")
	
	local button = frame:WaitForChild("Button")

	RbxDono10.Frame = frame
	RbxDono10.Button = button

	if onClickConn then onClickConn:Disconnect() end

	onClickConn = RbxDono10.Button.MouseButton1Click:Connect(function()
		PurchaseService.PromptProductPurchase(3563151096)
	end)

	print("[RbxDono10] Initialised")
end

return RbxDono10