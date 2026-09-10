local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes.IslandTravelEvents

local DataHandler = require(ServerStorage.Game.Systems:WaitForChild("DataHandler"))
local IslandTravelInfo = require(ReplicatedStorage.Data.IslandTravel:WaitForChild("IslandTravelInfo"))

local IslandTravelHandler = {}

function IslandTravelHandler.GoTo(player, location, ignoreRequirements)
	ignoreRequirements = ignoreRequirements and true or false
	
	local data = DataHandler.GetData(player)
	if not data then return end
	
	local char = player.Character
	if not char then return end
	
	local hum = char:FindFirstChild("Humanoid")
	if not hum or hum.Health <= 0 then return end
	
	local playerLevel = data.Stats.Level
	local playerCoins = data.Stats.Coins
	
	local islandInfo = IslandTravelInfo.Info[location]
	if not islandInfo then 
		warn("[IslandTravelHandler] Invalid location:", location)
		return 'InvalidLocation'
	end
	
	local locationGoToPart = workspace.Places:FindFirstChild(location):FindFirstChild("GoTo")
	if not locationGoToPart then
		warn("[IslandTravelHandler] No GoTo part in", location)
		return 'InvalidLocation'
	end
	
	if not ignoreRequirements then
		if playerLevel < islandInfo.LevelRequirement then
			return 'LevelRequirement'
		end

		if playerCoins < islandInfo.Cost then
			return 'CoinsRequirement'
		end
		
		IslandTravelHandler.LoadTravelEvent:FireClient(player, location)

		local newCoins = data.Stats.Coins - islandInfo.Cost
		DataHandler.SetStat(player, 'Coins', newCoins)
	end
	
	char:MoveTo(locationGoToPart.Position)
	return
end

--local function tempMakePrompt(from, to)
--	local fromPart = workspace.Places:FindFirstChild(from):FindFirstChild("GoTo")
--	if not fromPart then
--		warn("[IslandTravelHandler] No GoTo part in", from)
--		return
--	end
	
--	local toPart = workspace.Places:FindFirstChild(to):FindFirstChild("GoTo")
--	if not toPart then
--		warn("[IslandTravelHandler] No GoTo part in", to)
--		return
--	end
	
--	local prompt = Instance.new("ProximityPrompt")
--	prompt.ActionText = "Level " .. IslandTravelInfo.Info[to].LevelRequirement .. " & "..IslandTravelInfo.Info[to].Cost .. " Coins"
--	prompt.ObjectText = "Go to " .. to
--	prompt.HoldDuration = 0.5
--	prompt.RequiresLineOfSight = false
--	prompt.MaxActivationDistance = 10
--	prompt.Enabled = true

--	prompt.Parent = fromPart
	
--	prompt.Triggered:Connect(function(player)
--		IslandTravelHandler.GoTo(player, to)
--	end)
--end

local function EventsInit()
	IslandTravelHandler.RequestTravelFunction = Instance.new("RemoteFunction")
	IslandTravelHandler.RequestTravelFunction.Name = "RequestTravel"
	IslandTravelHandler.RequestTravelFunction.Parent = Remotes
	IslandTravelHandler.RequestTravelFunction.OnServerInvoke = IslandTravelHandler.GoTo
	
	IslandTravelHandler.LoadTravelEvent = Instance.new("RemoteEvent")
	IslandTravelHandler.LoadTravelEvent.Name = "LoadTravel"
	IslandTravelHandler.LoadTravelEvent.Parent = Remotes
end

function IslandTravelHandler.Init()
	EventsInit()
	local islands = workspace.Places:GetChildren()
	
	print("[IslandTravelHandler] IslandTravelHandler initialised")
end

return IslandTravelHandler
