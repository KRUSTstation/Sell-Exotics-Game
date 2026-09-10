local ShopMenu = {}
ShopMenu.__index = ShopMenu

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.Game.Client:FindFirstChild("Controllers")

local UIController
local DataController = require(Controllers:WaitForChild("DataController"))
local TweenHelper = require(script.Parent:WaitForChild("TweenHelper"))

local UserInputService = game:GetService("UserInputService")

local isTouch = UserInputService.TouchEnabled

local UIInfo = {}
local TabHoverConns = {}

local onClickConn

ShopMenu.OpenGrid = nil

function ShopMenu.close()
	if UIController.CurrentlyOpenUI == script then UIController.CurrentlyOpenUI = nil end

	local t = TweenHelper.MainUITween(ShopMenu.Frame, false)
	t.Completed:Wait()

	ShopMenu.Frame.Visible = false
end

function ShopMenu.open()
	UIController.CurrentlyOpenUI = script

	ShopMenu.Frame.Visible = true
	TweenHelper.MainUITween(ShopMenu.Frame, true)
end

local function handleHoverTabBar(tabBar: Instance, button: Instance, isHoverOn: boolean)	
	if ShopMenu.TabBarHovers[tabBar] then ShopMenu.TabBarHovers[tabBar]() end
	
	if not tabBar:IsA("ImageLabel") or not button.Active then return end
	
	local t1
	
	if isHoverOn then
		t1 = TweenService:Create(tabBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UIInfo[tabBar].Position + UDim2.new(0, 0, 0.165, 0)})
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
	if ShopMenu.TabBarPaused[tabBar] then return end

	if ShopMenu.TabBarToggles[tabBar] then ShopMenu.TabBarToggles[tabBar]() end
	
	local grid = ShopMenu.Tabs:FindFirstChild(tabBar.Name)
	if not grid then warn("No grid for "..tabBar.Name); return end
	
	if ShopMenu.OpenGrid == grid then return end
	
	if ShopMenu.OpenGrid then
		ShopMenu.OpenGrid.Visible = false
	end
	
	ShopMenu.OpenGrid = grid
	ShopMenu.OpenGrid.Visible = true
end

function ShopMenu.Pause()
	if ShopMenu.Paused then return end
	ShopMenu.Paused = true
end

function ShopMenu.Resume()
	if not ShopMenu.Paused then return end
	ShopMenu.Paused = false
end

function ShopMenu.ConnectToggle(func)
	if not func then return end

	ShopMenu.OnToggle = func
end

function ShopMenu.RemoveToggle()
	ShopMenu.OnToggle = nil
end

function ShopMenu.PauseTabBar(tabBar: Instance)
	if ShopMenu.TabBarPaused[tabBar] then return end
	ShopMenu.TabBarPaused[tabBar] = true
end

function ShopMenu.ResumeTabBar(tabBar: Instance)
	if not ShopMenu.TabBarPaused[tabBar] then return end
	ShopMenu.TabBarPaused[tabBar] = false
end

function ShopMenu.ConnectTabBarHover(tabBar: Instance, func)
	if not func then return end
	ShopMenu.TabBarHovers[tabBar] = func
end

function ShopMenu.ConnectTabBarToggle(tabBar: Instance, func)
	if not func then return end
	ShopMenu.TabBarToggles[tabBar] = func
end

function ShopMenu.RemoveTabBarHover(tabBar: Instance)
	ShopMenu.TabBarHovers[tabBar] = nil
end

function ShopMenu.RemoveTabBarToggle(tabBar: Instance)
	ShopMenu.TabBarToggles[tabBar] = nil
end
	
function ShopMenu.Init(uiController)
	if not uiController then return end

	UIController = uiController

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local ui = gameUI:WaitForChild("Shop")
	local mainUi = gameUI:WaitForChild("Main")

	local frame = ui:WaitForChild("Frame")
	local tabsBars = frame:WaitForChild("TabsBars")
	local tabs = frame:WaitForChild("Tabs")
	--local closeButton = frame:WaitForChild("CloseButton")
	local openButton = mainUi.Frame.Menu.Submenu:WaitForChild("ShopButton")
	
	ShopMenu.Paused = false
	ShopMenu.OnToggle = nil
	
	ShopMenu.TabBarPaused = {}
	ShopMenu.TabBarHovers = {}
	
	ShopMenu.TabBarToggles = {}

	ShopMenu.UI = ui
	ShopMenu.Frame = frame
	ShopMenu.OpenButton = openButton
	ShopMenu.TabsBars = tabsBars
	ShopMenu.Tabs = tabs
	--ShopMenu.CloseButton = closeButton

	ShopMenu.UI.Frame.Visible = false
	
	for _, child in pairs(ShopMenu.TabsBars:GetChildren()) do
		if not UIInfo[child] then
			UIInfo[child] = {Position = child.Position, Size = child.Size}
		end
	end
	
	for tabBar, conns in pairs(TabHoverConns) do
		if tabBar.Name ~= "Donations" then ShopMenu.Tabs:FindFirstChild(tabBar.Name).Visible = false end
		for _, conn in pairs(conns) do
			conn:Disconnect()
		end
	end
	
	ShopMenu.OpenGrid = ShopMenu.Tabs:FindFirstChild("Donations")
	
	for _, tabBar in pairs(ShopMenu.TabsBars:GetChildren()) do
		TabHoverConns[tabBar] = {}
		
		local button = tabBar.Button
		table.insert(TabHoverConns[tabBar], button.MouseButton1Click:Connect(function() -- TODO: make this work on mobile
			handleClickTabBar(tabBar)
		end))
		
		if tabBar.Name == "Donations" then continue end
		
		local smallButton = tabBar.SmallButton
		
		button.Active = false
		smallButton.Active = true
		if not isTouch then
			table.insert(TabHoverConns[tabBar], smallButton.MouseEnter:Connect(function()
				handleHoverTabBar(tabBar, smallButton, true)
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
		else
			ShopMenu.Phone = {}
			ShopMenu.Phone.Activate = true
			
			table.insert(TabHoverConns[tabBar], smallButton.Activated:Connect(function()
				handleHoverTabBar(tabBar, smallButton, ShopMenu.Phone.Activate)
				ShopMenu.Phone.Activate = not ShopMenu.Phone.Activate
			end))

			table.insert(TabHoverConns[tabBar], button.Activated:Connect(function()
				handleHoverTabBar(tabBar, smallButton, ShopMenu.Phone.Activate)
				ShopMenu.Phone.Activate = not ShopMenu.Phone.Activate
			end))
		end
	end

	if onClickConn then onClickConn:Disconnect() end

	onClickConn = ShopMenu.OpenButton.MouseButton1Click:Connect(function()
		if ShopMenu.Paused then return end
		if ShopMenu.OnToggle then ShopMenu.OnToggle() end
		
		if ShopMenu.UI.Frame.Visible then
			ShopMenu.close()
		else
			ShopMenu.open()
		end
	end)

	--ShopMenu.CloseButton.MouseButton1Click:Connect(function()
	--	ShopMenu.close()
	--end)

	print("[ShopMenu] Initialised")
end

return ShopMenu