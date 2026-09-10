local Startup = {}
Startup.__index = Startup

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.Game.Client:WaitForChild("Controllers")
local Services = ReplicatedStorage.Game.Client:WaitForChild("Services")

local LoadingService = require(Services:WaitForChild("LoadingService"))

local UIController

function Startup.StartLoad()
	LoadingService.LoadAll(function(loaded, total)
		Startup.PercentageText.Text = tostring(math.floor(loaded / total * 100)) .. "%"
	end)
	
	local Game = require(ReplicatedStorage.Game)
	Game.Init()
	Startup.PercentageText.Text = "100%"
	task.wait(1)
	
	local t = TweenService:Create(Startup.Frame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, -1, 0)})
	t:Play()
	t.Completed:Wait()	
	
	Startup.Frame.Visible = false
	Startup.UI:Destroy()
end

function Startup.Load(uiController)
	UIController = uiController

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local ui = playerGui:WaitForChild("Startup")

	local frame = ui:WaitForChild("Frame")
	local percentageText = frame:WaitForChild("Percentage")

	Startup.UI = ui
	Startup.Frame = frame
	Startup.PercentageText = percentageText
	
	Startup.Frame.Visible = true
	Startup.StartLoad()
end

return Startup