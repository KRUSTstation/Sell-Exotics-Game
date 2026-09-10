local SettingsMenu = {}
SettingsMenu.__index = SettingsMenu

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.Game.Client:FindFirstChild("Controllers")

local UIController
local DataController = require(Controllers:WaitForChild("DataController"))
local TweenHelper = require(script.Parent:WaitForChild("TweenHelper"))

local UIInfo = {}
local TabHoverConns = {}

local onClickConn

function SettingsMenu.close()
	if UIController.CurrentlyOpenUI == script then UIController.CurrentlyOpenUI = nil end

	local t = TweenHelper.MainUITween(SettingsMenu.Frame, false)
	t.Completed:Wait()

	SettingsMenu.Frame.Visible = false
end

function SettingsMenu.open()
	UIController.CurrentlyOpenUI = script

	SettingsMenu.Frame.Visible = true
	TweenHelper.MainUITween(SettingsMenu.Frame, true)
end

local function handleHoverTabBar(tabBar: Instance, button: Instance, isHoverOn: boolean)
	if not tabBar:IsA("ImageLabel") or not button.Active then return end

	local t1

	if isHoverOn then
		t1 = TweenService:Create(tabBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = tabBar.Position + UDim2.new(0, 0, 0.1, 0)})
		tabBar.SmallButton.Active = false
		tabBar.Button.Active = true
	else
		t1 = TweenService:Create(tabBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UIInfo[tabBar].Position})
		tabBar.SmallButton.Active = true
		tabBar.Button.Active = false
	end

	t1:Play()
end

local function handleClickTabBar(tabBar: Instance)
	
end

function SettingsMenu.Init(uiController)
	if not uiController then return end

	UIController = uiController

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local ui = gameUI:WaitForChild("Settings")
	local mainUi = gameUI:WaitForChild("Main")

	local frame = ui:WaitForChild("Frame")
	local tabsBars = frame:WaitForChild("TabsBars")
	--local tabs = frame:WaitForChild("Tabs")
	--local closeButton = frame:WaitForChild("CloseButton")
	local openButton = mainUi.Frame.Menu.Stored:WaitForChild("SettingsButton")

	SettingsMenu.UI = ui
	SettingsMenu.Frame = frame
	SettingsMenu.OpenButton = openButton
	SettingsMenu.TabsBars = tabsBars
	--SettingsMenu.Tabs = tabs
	--SettingsMenu.CloseButton = closeButton

	SettingsMenu.UI.Frame.Visible = false

	for _, child in pairs(SettingsMenu.TabsBars:GetChildren()) do
		if not UIInfo[child] then
			UIInfo[child] = {Position = child.Position, Size = child.Size}
		end
	end

	for tabBar, conns in pairs(TabHoverConns) do
		for _, conn in pairs(conns) do
			conn:Disconnect()
		end
	end

	for _, tabBar in pairs(SettingsMenu.TabsBars:GetChildren()) do
		if tabBar.Name == "Game" then continue end

		local button = tabBar.Button
		local smallButton = tabBar.SmallButton

		button.Active = false
		smallButton.Active = true

		TabHoverConns[tabBar] = {}

		table.insert(TabHoverConns[tabBar], smallButton.MouseEnter:Connect(function()
			handleHoverTabBar(tabBar, smallButton, true)
		end))

		table.insert(TabHoverConns[tabBar], smallButton.MouseLeave:Connect(function()
			handleHoverTabBar(tabBar, smallButton, false)
		end))
		
		table.insert(TabHoverConns[tabBar], smallButton.MouseLeave:Connect(function()
			handleHoverTabBar(tabBar, smallButton, false)
		end))

		table.insert(TabHoverConns[tabBar], button.MouseEnter:Connect(function()
			handleHoverTabBar(tabBar, button, true)
		end))

		table.insert(TabHoverConns[tabBar], button.MouseLeave:Connect(function()
			handleHoverTabBar(tabBar, button, false)
		end))
	end

	if onClickConn then onClickConn:Disconnect() end

	onClickConn = SettingsMenu.OpenButton.MouseButton1Click:Connect(function()
		if SettingsMenu.UI.Frame.Visible then
			SettingsMenu.close()
		else
			SettingsMenu.open()
		end
	end)

	--SettingsMenu.CloseButton.MouseButton1Click:Connect(function()
	--	SettingsMenu.close()
	--end)

	print("[SettingsMenu] Initialised")
end



return SettingsMenu