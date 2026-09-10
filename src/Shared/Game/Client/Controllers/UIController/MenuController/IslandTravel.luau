local IslandTravel = {}
IslandTravel.__index = IslandTravel

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.Game.Client:FindFirstChild("Controllers")

local DataController = require(Controllers:WaitForChild("DataController"))
local TweenHelper = require(script.Parent:WaitForChild("TweenHelper"))
local NotifController = require(Controllers:WaitForChild("UIController"):WaitForChild("NotifController"))

local Remotes = ReplicatedStorage.Remotes.IslandTravelEvents
local RequestTravelFunction = Remotes:WaitForChild("RequestTravel")
local LoadTravelEvent = Remotes:WaitForChild("LoadTravel")

local States = {}

local UIController

function IslandTravel.close()
	if UIController.CurrentlyOpenUI == script then UIController.CurrentlyOpenUI = nil end
	
	local t = TweenHelper.MainUITween(IslandTravel.Frame, false)
	t.Completed:Wait()
	
	IslandTravel.Frame.Visible = false
end

function IslandTravel.open()
	UIController.CurrentlyOpenUI = script
	
	IslandTravel.Frame.Visible = true
	TweenHelper.MainUITween(IslandTravel.Frame, true)
end

local function HandleRequestTravelResponse(response)	
	if not response then IslandTravel.close(); return end
	
	if response == "LevelRequirement" then
		NotifController.NoLevelNotif()
		
		--UIController.OpenUI("LevelUp")
	elseif response == "CoinsRequirement" then
		-- coordinate with the waypoints, if the player waypoint is set there make this bypass the requirement for coins
		
		NotifController.NoMoneyNotif()
		--UIController.OpenUI("Shop")
	end
end

local function InitialiseIslands()
	-- can add a check for if player has unlocked an island and has enough funds
	
	for _, island in pairs(IslandTravel.Grid:GetChildren()) do
		if island:IsA("Frame") then
			local button = island:FindFirstChild("Button")
			if not button then continue end

			local image = island:FindFirstChild("Background")
			if not image then continue end
			
			States[image] = {Size = image.Size, Position = image.Position}
			
			button.MouseEnter:Connect(function()
				local image = image
				
				TweenService:Create(image, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = States[image].Size + UDim2.new(0.05, 0, 0.05, 0)}):Play()
			end)
			
			button.MouseLeave:Connect(function()
				local image = image
				
				TweenService:Create(image, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = States[image].Size}):Play()
			end)
		end
	end
	
	IslandTravel.GrassLands.MouseButton1Click:Connect(function()
		local response = RequestTravelFunction:InvokeServer("GrassLands")
		HandleRequestTravelResponse(response)
	end)
	IslandTravel.Jungle.MouseButton1Click:Connect(function()
		local response = RequestTravelFunction:InvokeServer("Jungle")
		HandleRequestTravelResponse(response)
	end)
	IslandTravel.IceLands.MouseButton1Click:Connect(function()
		local response = RequestTravelFunction:InvokeServer("IceLands")
		HandleRequestTravelResponse(response)
	end)
end

function IslandTravel.Pause()
	if IslandTravel.Paused then return end
	IslandTravel.Paused = true
end

function IslandTravel.Resume()
	if not IslandTravel.Paused then return end
	IslandTravel.Paused = false
end

function IslandTravel.ConnectToggle(func)
	if not func then return end

	IslandTravel.OnToggle = func
end

function IslandTravel.RemoveToggle()
	IslandTravel.OnToggle = nil
end

function IslandTravel.Init(uiController)
	if not uiController then return end

	UIController = uiController
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local ui = gameUI:WaitForChild("IslandTravel")
	local main = gameUI:WaitForChild("Main")

	local frame = ui:WaitForChild("Frame")
	local grid = frame:WaitForChild("Grid")
	--local closeButton = frame:WaitForChild("CloseButton")
	local openButton = main.Frame.Menu.Submenu:WaitForChild("IslandTravelButton")
	
	local grassLands = grid:WaitForChild("GrassLands"):WaitForChild("Button")
	local jungle = grid:WaitForChild("Jungle"):WaitForChild("Button")
	local iceLands = grid:WaitForChild("IceLands"):WaitForChild("Button")
	
	IslandTravel.Paused = false
	IslandTravel.OnToggle = nil

	IslandTravel.UI = ui
	IslandTravel.Frame = frame
	IslandTravel.Grid = grid
	IslandTravel.OpenButton = openButton
	--IslandTravel.CloseButton = closeButton
	
	IslandTravel.GrassLands = grassLands
	IslandTravel.Jungle = jungle
	IslandTravel.IceLands = iceLands
	
	InitialiseIslands()

	IslandTravel.UI.Frame.Visible = false

	IslandTravel.OpenButton.MouseButton1Click:Connect(function()
		if IslandTravel.Paused then return end
		if IslandTravel.OnToggle then IslandTravel.OnToggle() end
		
		if IslandTravel.UI.Frame.Visible then
			IslandTravel.close()
		else
			IslandTravel.open()
		end
	end)

	--IslandTravel.CloseButton.MouseButton1Click:Connect(function()
	--	IslandTravel.close()
	--end)
	print("[IslandTravel] Initialised")
end

return IslandTravel
