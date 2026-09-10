local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes.DataEvents.TutorialEvents

local TutorialHandler = {}

function TutorialHandler.StartTutorial(player, tutorial)
	local response = TutorialHandler.StartTutorialFunction:InvokeClient(player, tutorial)
	if not response then return end
	
	if response == "completed" then
		local data = TutorialHandler.DataHandler.GetData(player)
		if not data then return end
		
		data.TutorialStages[tutorial] = true
		
		TutorialHandler.DataHandler.SetData(player, data)
	end
end

function TutorialHandler.InitiateMainTutorial(player)
	local data
	local attempts = 0
	
	repeat 
		data = TutorialHandler.DataHandler.GetData(player)
		task.wait(0.5)
		attempts += 1
	until data or attempts > 3
	
	if not data then return end
	
	if data.TutorialStages.MainTutorial then
		return
	end
	
	task.wait(3)
	
	TutorialHandler.StartTutorial(player, "MainTutorial")
end

function TutorialHandler.InitiateUpgradeTutorial(player)
	local data
	local attempts = 0
	
	repeat 
		data = TutorialHandler.DataHandler.GetData(player)
		task.wait(0.5)
		attempts += 1
	until data or attempts > 3

	if not data then return end
	if data.TutorialStages.UpgradeTutorial and data.TutorialStages.UpgradeTutorial == 'completed' then
		return
	end
	
	local UpgradeInfo = require(ReplicatedStorage.Data.Upgrades:WaitForChild("UpgradeInfo"))
	
	local lowestCost
	for name, info in pairs(UpgradeInfo) do
		if not lowestCost or info.Price(1) < lowestCost then
			lowestCost = info.Price(1)
		end
	end
	
	while true do
		task.wait(5)
		
		local data
		local attempts = 0

		repeat 
			data = TutorialHandler.DataHandler.GetData(player)
			task.wait(0.5)
			attempts += 1
		until data or attempts > 3
		
		if data.Stats.Coins < lowestCost then continue end
		TutorialHandler.StartTutorial(player, "UpgradeTutorial")
		break
	end
end

local function EventsInit()
	TutorialHandler.StartTutorialFunction = Instance.new("RemoteFunction")
	TutorialHandler.StartTutorialFunction.Name = "StartTutorial"
	TutorialHandler.StartTutorialFunction.Parent = Remotes
	--TutorialHandler.StartTutorialFunction.OnServerInvoke = TutorialHandler.StartTutorial -- can uncomment this once we have other mechanics
end

function TutorialHandler.Init(dataHandler)
	if not dataHandler then return end

	TutorialHandler.DataHandler = dataHandler
	
	EventsInit()

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			TutorialHandler.InitiateMainTutorial(player)
			TutorialHandler.InitiateUpgradeTutorial(player)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			TutorialHandler.InitiateMainTutorial(player)
			TutorialHandler.InitiateUpgradeTutorial(player)
		end)
	end)

	print('[TutorialHandler] Initialised')
end

return TutorialHandler
