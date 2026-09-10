local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Debris = game:GetService("Debris")

local Rarities = require(ServerStorage.Data.Spawns:WaitForChild("Rarities"))
local Weights = require(ServerStorage.Data.Spawns:WaitForChild("Weights"))
local SpawnInfo = require(ServerStorage.Data.Spawns:WaitForChild("SpawnInfo"))
local SpawnAugments = require(ServerStorage.Data.Spawns:WaitForChild("SpawnAugments"))

local SpawnControllers = require(script:WaitForChild("SpawnControllers"))
local SpawnEffects = require(script:WaitForChild("SpawnEffects"))
local Behaviours = require(script:WaitForChild("Behaviours"))

local MutationHandler = require(script:WaitForChild("MutationHandler"))

local Remotes = ReplicatedStorage.Remotes.SpawningEvents

local Collection
local WeightsHelper

local Spawning = {}

local PlayerSpecificSpawns = {}

local MAX_SCALE = 1.6
local MIN_SCALE = 0.5

local SPAWNING_DELAY = 4

local function SetAnchored(object, state)
	if object:IsA("BasePart") then
		object.Anchored = state
	elseif object:IsA("Model") then
		for _, part in ipairs(object:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = state
			end
		end
	end
end

local function ScaleModel(model, scale)
	model:ScaleTo(scale)

	local randomYaw = math.rad(math.random() * 360)
	model:PivotTo(model:GetPivot() * CFrame.Angles(0, randomYaw, 0))
end

local function ApplySpawnAugments(level, ctx)
	local model = ctx.Model
	local animal_name = model.Name
	
	local augment = SpawnAugments[level.Name][animal_name]
	if not augment then return end

	if augment.Effects then
		for _, effectName in ipairs(augment.Effects) do
			local effectModule = SpawnEffects[effectName]
			if effectModule then
				effectModule.Attach(model)
			end
		end
	end

	if augment.Controller then
		local controllerModule = SpawnControllers[augment.Controller]
		if controllerModule then
			controllerModule.Control(ctx)
		end
	end
end

local function AlignToGround(model)
	local cf, size = model:GetBoundingBox()
	local origin = cf.Position + Vector3.new(0, size.Y, 0)
	local direction = Vector3.new(0, -size.Y * 3, 0)

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {model}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction, params)
	if result then
		local pos = Vector3.new(cf.X, result.Position.Y + (size.Y / 2), cf.Z)
		model:PivotTo(CFrame.new(pos) * (cf - cf.Position))
	end
end

function Spawning.SpawnInArea(spawnArea: BasePart, objectTemplate: Model, count: number, offsetAboveGround: number, exclusiveToPlayer: Player)
	if exclusiveToPlayer and PlayerSpecificSpawns[exclusiveToPlayer] then
		PlayerSpecificSpawns[exclusiveToPlayer]:Destroy()	
	end
	
	local folder = workspace:WaitForChild("Spawns"):FindFirstChild(spawnArea.Name)
	local trees = workspace:FindFirstChild("Trees"):FindFirstChild(spawnArea.Name)
	
	local animal_name = objectTemplate.Name
	
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = spawnArea.Name
		folder.Parent = workspace:WaitForChild("Spawns")
	end

	offsetAboveGround = offsetAboveGround or 5

	local min = spawnArea.Position - (spawnArea.Size / 2)
	local max = spawnArea.Position + (spawnArea.Size / 2)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {spawnArea, trees}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	for i = 1, count do
		local x = math.random() * (max.X - min.X) + min.X
		local z = math.random() * (max.Z - min.Z) + min.Z
		local yTop = max.Y + 50

		local origin = Vector3.new(x, yTop, z)
		local direction = Vector3.new(0, -500, 0)
		local result = workspace:Raycast(origin, direction, raycastParams)

		if result then			
			local pos = result.Position + Vector3.new(0, offsetAboveGround, 0)
			
			local clone = objectTemplate:Clone()
			
			if exclusiveToPlayer then
				clone:SetAttribute("ExclusiveToPlayer", exclusiveToPlayer.UserId)
			end
			
			clone.Parent = folder

			local weight = exclusiveToPlayer and 1 or WeightsHelper.RandomAnimalWeight(animal_name)
			local weightData = Weights[animal_name]
			clone:SetAttribute("Weight", weight)
			
			local normalized = (weight - weightData.Low) / (weightData.High - weightData.Low)
			local scale = math.clamp(MIN_SCALE + normalized * (MAX_SCALE - MIN_SCALE), MIN_SCALE, MAX_SCALE)
			
			ScaleModel(clone, scale)
			clone:SetAttribute("Scale", scale)
			
			local ctx = {
				Model = clone,
				SpawnArea = spawnArea,
				RaycastResult = result,
				SpawnInfoData = SpawnInfo[animal_name],
				Mutations = MutationHandler.GetMutations(),
				Trees = trees,
				Water = workspace:FindFirstChild("Water"),
				OffsetAboveGround = offsetAboveGround,
			}
			
			local handled = false
			local behaviours = SpawnInfo[animal_name].Behaviours
			
			if behaviours then
				for _, behaviourName in ipairs(behaviours) do
					local behaviour = Behaviours[behaviourName]
					if behaviour and behaviour.Apply then
						if behaviour.Apply(ctx) then
							handled = true
							break
						end
					end
				end
			end

			if not handled then
				clone:Destroy()
				continue
			end
			
			MutationHandler.ApplyMutations(ctx)
			
			SetAnchored(ctx.Model, true)
			
			Debris:AddItem(ctx.Model, exclusiveToPlayer and math.huge or SpawnInfo[animal_name].TimeToDespawn)
			if exclusiveToPlayer then PlayerSpecificSpawns[exclusiveToPlayer] = ctx.Model end
			
			Collection.SetupPrompt(spawnArea.Name, ctx.Model, animal_name, weight, exclusiveToPlayer)
			ApplySpawnAugments(spawnArea, ctx)
			print(("[Spawning] Spawned %s in %s"):format(ctx.Model.Name, spawnArea.Name))
		else
			warn(("[Spawning] No ground hit at X, Z: (%.1f, %.1f)"):format(x, z))
		end
	end
end

function Spawning.ChooseAnimal(spawnArea: string)
	local total = 0
	for _, info in pairs(Rarities[spawnArea]) do
		local rarity = info.Rarity
		total += 1 / rarity
	end

	local rng = math.random()
	local counter = 0

	for animal, info in pairs(Rarities[spawnArea]) do
		local rarity = info.Rarity
		counter += 1 / rarity / total
		if rng <= counter then
			return animal
		end
	end
end

function Spawning.SpawnDummy(player)
	local animal = "Chicken"
	
	local spawnArea = ServerStorage.SpawnAreas:FindFirstChild("GrassLands")
	local animalMesh = ReplicatedStorage.Assets.Meshes.Animals:FindFirstChild(animal)
	
	Spawning.SpawnInArea(spawnArea, animalMesh, 1, 5, player)
end

function Spawning.Start()
	task.spawn(function()
		while true do
			for area, _ in pairs(Rarities) do
				local animal = Spawning.ChooseAnimal(area)
				if not animal then continue end
				
				local spawnArea = ServerStorage.SpawnAreas:FindFirstChild(area)
				
				local animalMesh = ReplicatedStorage.Assets.Meshes.Animals:FindFirstChild(animal)

				if not spawnArea then
					warn(("[Spawning] %s area not found"):format(area))
				elseif not animalMesh then
					warn(("[Spawning] %s animal mesh not found"):format(animal))
				else
					Spawning.SpawnInArea(spawnArea, animalMesh, 1)
				end
			end
			task.wait(SPAWNING_DELAY)
		end
	end)
end

local function EventsInit()
	Spawning.SpawnDummyEvent = Instance.new('RemoteEvent')
	Spawning.SpawnDummyEvent.Name = 'SpawnDummy'
	Spawning.SpawnDummyEvent.Parent = Remotes
	Spawning.SpawnDummyEvent.OnServerEvent:Connect(Spawning.SpawnDummy)
end

function Spawning.Init()
	EventsInit()
	
	Collection = require(ServerStorage.Game.Systems:WaitForChild("CollectionsHandler"))
	WeightsHelper = require(ServerStorage.Game.Systems:WaitForChild("WeightsHelper"))

	print("[Spawning] Spawning initialization complete.")
end

return Spawning
