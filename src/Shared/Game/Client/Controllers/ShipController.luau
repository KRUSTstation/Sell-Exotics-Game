local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SFX = ReplicatedStorage.Assets.SFX.Game

local SellingController = require(ReplicatedStorage.Game.Client.Controllers:WaitForChild("SellingController"))
local MusicService = require(ReplicatedStorage.Game.Client.Services:WaitForChild("MusicService"))
local EffectHandler = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("EffectHandler"))

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local PlayShipCutsceneEvent = ReplicatedStorage.Remotes.SellingEvents.ShipEvents:WaitForChild("PlayShipCutsceneFunction")

local ShipController = {}

local ship = workspace.SpawnArea:WaitForChild("Ship")

local initialTweenTime = 8

local cd = false

local function TweenModel(model: Model, targetCFrame: CFrame, tweenInfo: TweenInfo)
	assert(model:IsA("Model"), "TweenModel expects a Model")

	local startCF = model:GetPivot()

	local alpha = Instance.new("NumberValue")
	alpha.Value = 0

	local tween = TweenService:Create(alpha, tweenInfo, { Value = 1 })

	local connection
	connection = alpha.Changed:Connect(function(v)
		model:PivotTo(startCF:Lerp(targetCFrame, v))
	end)

	tween.Completed:Connect(function()
		connection:Disconnect()
		alpha:Destroy()
	end)

	tween:Play()
	return tween
end

function ShipController.InitialShipCutscene(distance)
	local distanceToMove = distance

	local startCF = ship:GetPivot()
	local endCF = startCF * CFrame.new(-distanceToMove, 0, 0)

	local tweenInfo = TweenInfo.new(
		initialTweenTime,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.In
	)

	local tween = TweenModel(ship, endCF, tweenInfo)
	--tween.Completed:Wait()
	return tween, startCF
end

local function EmitLightning()
	EffectHandler.PlayEffect("Lightning", ship)
end

function ShipController.SellFailShipCutscene()
	task.wait(3)
	MusicService.Pause()
	task.wait(1)
	local tweenInfo = TweenInfo.new(initialTweenTime-6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(game.Lighting, tweenInfo, {ClockTime = 18, Brightness = 1})
	
	local suspense = SFX:WaitForChild("Unsettling Aftermath - Sting 2")
	local fah = SFX:WaitForChild("FAHHHHH pump sound")
	local lighting = SFX:WaitForChild("lightning_strike")
	
	suspense.TimePosition = 2
	
	suspense:Play()
	tween:Play()
	tween.Completed:Wait()
	task.wait(2)
	
	EmitLightning()
	lighting:Play()
	fah:Play()
	ShipController.ShipFadeOut(0.2)
	return
end

local function SetTransparency(transparency)
	for _,i in pairs(ship:GetChildren()) do
		if i.Name ~= 'Sell' then
			i.Transparency = transparency
		end
	end
end

function ShipController.ShipFadeOut(tween_time)
	SetTransparency(0)
	local tween
	
	for _,m in pairs(ship:GetChildren()) do
		if m.Name ~= 'Sell' then
			tween = TweenService:Create(m, TweenInfo.new(tween_time), {Transparency = 1})
			tween:Play()
		end
	end
	tween.Completed:Wait()
	return
end

function ShipController.ShipReturnCutscene(endCF)
	local distanceToMove = 20
	local tweenTime = 4
	
	local startCF = endCF * CFrame.new(0, -distanceToMove, 0)
	ship:PivotTo(startCF)
	
	while ship.PrimaryPart.Transparency > 0 do
		SetTransparency(0)
		task.wait(0.01)
	end
	
	local tweenInfo = TweenInfo.new(
		tweenTime,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local tween = TweenModel(ship, endCF, tweenInfo)
	tween:Play()
	
	local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(game.Lighting, tweenInfo, {ClockTime = 10, Brightness = 3}) -- TODO: add a new clock controller to get/change the current clock and brightness using another module from server side (more reliable)

	tween:Play()
	tween.Completed:Wait()
	
	if ship.PrimaryPart.Transparency > 0 then
		SetTransparency(0)
	end
	
	return
end

function ShipController.PlayFullCutscene(isStorm)
	local iniTween, startCF
	
	if cd then return false end
	
	cd = true
	
	if isStorm then
		iniTween, startCF = ShipController.InitialShipCutscene(150)
		ShipController.SellFailShipCutscene()
		task.delay(1, MusicService.Resume)
	else
		iniTween, startCF = ShipController.InitialShipCutscene(300)
		task.delay(initialTweenTime - 1, function()
			ShipController.ShipFadeOut(1)
		end) 
		iniTween.Completed:Wait()
	end
	
	task.spawn(function()
		local finished = ShipController.ShipReturnCutscene(startCF)
		cd = false
	end)
	
	return true
end

local function SellingPromptInit()
	local sellNPC = workspace.SpawnArea.Ship:WaitForChild("Sell")
	local proxPrompt = sellNPC:WaitForChild("ProximityPrompt")
	
	proxPrompt.PromptShown:Connect(function()
		local total = SellingController.GetTotalPrice()

		if total then
			proxPrompt.ActionText = ("%.2f coins"):format(total)
		else
			proxPrompt.ActionText = "No animals to sell"
		end
	end)

	proxPrompt.PromptHidden:Connect(function()
		proxPrompt.ActionText = ""
	end)
end


function ShipController.Init()
	SellingPromptInit()
	
	PlayShipCutsceneEvent.OnClientInvoke = ShipController.PlayFullCutscene
	print("[ShipController] ShipController initialization complete.")
end

return ShipController

