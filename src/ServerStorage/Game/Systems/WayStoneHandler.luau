local WayStoneHandler = {}

local ServerStorage = game:GetService("ServerStorage")
local DataHandler = require(ServerStorage.Game.Systems:WaitForChild("DataHandler"))

local Players = game:GetService("Players")

local WayStones = workspace.Waystones:GetChildren()

function WayStoneHandler.UpdateWayStone(player, waystone)
	local data = DataHandler.GetData(player)
	if not data then return end
	
	DataHandler.SetWayStone(player, waystone.Name)
end

local function promptInit()
	for _, waystone in pairs(WayStones) do
		local prompt = waystone:FindFirstChild("ProximityPrompt") or Instance.new("ProximityPrompt")
		prompt.ActionText = "Set Waystone"
		prompt.ObjectText = waystone.Name
		prompt.Parent = waystone
		prompt.RequiresLineOfSight = false
		prompt.HoldDuration = 1
		prompt.MaxActivationDistance = 10
		
		prompt.Triggered:Connect(function(player)
			WayStoneHandler.UpdateWayStone(player, waystone)
		end)
	end
end

local function getRandomPointOnTop(part, character)
	local size = part.Size
	local cf = part.CFrame

	local xOffset = (math.random() - 0.5) * size.X
	local zOffset = (math.random() - 0.5) * size.Z

	local yOffset = size.Y / 2

	local worldPosition =
		cf.Position
		+ cf.RightVector * xOffset
		+ cf.LookVector * zOffset
		+ cf.UpVector * yOffset

	local hrp = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	local rootHeight = humanoid.HipHeight + hrp.Size.Y / 2

	return CFrame.new(worldPosition + cf.UpVector * rootHeight)
end

local function getWaystoneParts(spawnPart)
	local waystoneModel = spawnPart:FindFirstAncestor("Waystone")
	if not waystoneModel then return {} end

	return waystoneModel:GetDescendants()
end

local function getSafeSpawnCF(part, char)
	local blacklist = { char }

	for _, inst in ipairs(getWaystoneParts(part)) do
		table.insert(blacklist, inst)
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = blacklist
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	for _ = 1, 10 do
		local cf = getRandomPointOnTop(part, char)

		local result = workspace:Raycast(
			cf.Position + Vector3.new(0, 5, 0),
			Vector3.new(0, -15, 0),
			rayParams
		)

		if result and result.Instance == part then
			return cf + Vector3.new(0, 5, 0)
		end
	end

	warn("Failed safe spawn, using center")
	return part.CFrame + Vector3.new(0, (part.Size.Y / 2) + 3, 0)
end

local function waitForData(player, timeout)
	timeout = timeout or 5
	local start = os.clock()

	while os.clock() - start < timeout do
		local data = DataHandler.GetData(player)
		if data then
			return data
		end
		task.wait()
	end

	return nil
end

local function onCharAdded(char)
	local player = Players:GetPlayerFromCharacter(char)
	if not player then return end

	local data = waitForData(player)
	if not data or not data.WayStoneLocation then return end

	local waystone = workspace.Waystones:FindFirstChild(data.WayStoneLocation)
	if not waystone then return end
	
	DataHandler.SetWayStone(player, waystone.Name)

	local spawnPart = waystone.Area:FindFirstChild("Spawn")
	if not spawnPart or not spawnPart:IsA("BasePart") then
		warn("Invalid spawn part in Waystone", waystone.Name)
		return
	end

	char:PivotTo(getSafeSpawnCF(spawnPart, char))
end

local function setupPlayer(player)
	player.CharacterAdded:Connect(onCharAdded)

	if player.Character then
		task.defer(onCharAdded, player.Character)
	end
end

function WayStoneHandler.Init()
	promptInit()
	
	for _, player in ipairs(Players:GetPlayers()) do
		setupPlayer(player)
	end
	
	Players.PlayerAdded:Connect(setupPlayer)
	
	print('[WayStoneHandler] WayStoneHandler initialised')
end

return WayStoneHandler
