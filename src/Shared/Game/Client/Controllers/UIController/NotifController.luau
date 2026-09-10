local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Remotes = ReplicatedStorage.Remotes.UIEvents.NotifEvents

local Templates = ReplicatedStorage.Assets.UI.Templates.Notifications
local SFX = ReplicatedStorage.Assets.SFX.UI

local FormatNumbers = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("FormatNumbers"))

local SendCustomNotifEvent = Remotes:WaitForChild("SendCustomNotif")
local InsufficientStrenghtNotifEvent = Remotes:WaitForChild("InsufficientStrenghtNotif")

local UIController

local ActiveNotifs = {}
local NotifController = {}

-- all in terms of scale btw
local Y_PADDING = 0
local Y_START = 1.5

local function GetPosition(index, height)
	return UDim2.new(0, 0, - (index) * (height + Y_PADDING), 0)
end

local function RemoveNotifFromTable(id)
	for i, info in pairs(ActiveNotifs) do
		if info.id == id then
			table.remove(ActiveNotifs, i)
			break
		end
	end
end

function NotifController.InsufficientStrengthNotif()
	NotifController.AddNotification("Insufficient strength!", Color3.new(1, 0.25098, 0), 2)
	SFX.Error:Play()
end

function NotifController.CoinsChangedNotif(amt:number)
	if amt > 0 then
		amt = "+ " .. tostring(FormatNumbers.formatBigNumber(amt))
	elseif amt < 0 then
		amt = "- " .. tostring(FormatNumbers.formatBigNumber(-amt))
	else
		return
	end
	
	NotifController.AddNotification(tostring(amt) .. " Coins", Color3.new(0.0941176, 0.694118, 0), 2)
	SFX["Ka-ching"]:Play()
end

function NotifController.MaxLevelNotif()
	NotifController.AddNotification("Max Level!", Color3.new(0.796078, 0, 0), 2)
	SFX.Error:Play()
end

function NotifController.NoLevelNotif()
	NotifController.AddNotification("Too low level!", Color3.new(0.796078, 0.568627, 0), 2)
	SFX.Error:Play()
end

function NotifController.NoMoneyNotif()
	NotifController.AddNotification("Not enough money!", Color3.new(0.870588, 0, 0.0156863), 2)
	SFX.Error:Play()
end

function NotifController.AddNotification(text: string, color: Color3, timeForAlive: number)
	local clone = NotifController.DefaultNotif:Clone()
	
	clone.Position = UDim2.new(0, 0, Y_START, 0)
	clone.Visible = true
	clone.TextLabel.Text = text
	clone.TextLabel.TextColor3 = color
	clone.Parent = NotifController.Frame
	
	local id = HttpService:GenerateGUID(false)
	
	local info = {
		id = id,
		Index = #ActiveNotifs + 1,
		Time = timeForAlive,
		Frame = clone,
	}
	
	table.insert(ActiveNotifs, info)
	
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	for i, notif in pairs(ActiveNotifs) do	
		local i = #ActiveNotifs - i
		
		local tween = TweenService:Create(notif.Frame, tweenInfo, {Position = GetPosition(i, notif.Frame.Size.Y.Scale)})
		tween:Play()
	end
	
	task.delay(timeForAlive, function()
		local info = info
		
		RemoveNotifFromTable(info.id)
		
		TweenService:Create(info.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, 0, info.Frame.Position.Y.Scale, 0)}):Play()
		TweenService:Create(info.Frame.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		local t = TweenService:Create(info.Frame.TextLabel.UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1})
		t:Play()
		
		task.spawn(function()
			t.Completed:Wait()
			info.Frame:Destroy()
		end)
		
		for i, notif in ipairs(ActiveNotifs) do
			local i = #ActiveNotifs - i
			
			TweenService:Create(
				notif.Frame,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = GetPosition(i, notif.Frame.Size.Y.Scale)}
			):Play()
		end
	end)
end

local function EventsInit()
	SendCustomNotifEvent.OnClientEvent:Connect(function(text, color, timeForAlive, sound)
		NotifController.AddNotification(text, color, timeForAlive)
		if sound then
			sound:Play()
		end
	end)
	InsufficientStrenghtNotifEvent.OnClientEvent:Connect(NotifController.InsufficientStrengthNotif)
end

function NotifController.Init(uicontroller)
	if not uicontroller then return end
	EventsInit()
	
	UIController = uicontroller
	
	local starterGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = starterGui:WaitForChild("GameUI")
	local notifs = gameUI:WaitForChild("Notifications")
	local frame = notifs:WaitForChild("Frame")
	
	NotifController.UI = notifs
	NotifController.Frame = frame

	-- Templates
	local defaultNotif = Templates:WaitForChild("DefaultNotif")
	
	NotifController.DefaultNotif = defaultNotif
	
	print("[NotifController] Initialised")
end

return NotifController
