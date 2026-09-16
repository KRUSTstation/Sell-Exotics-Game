local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local EnemyTypes = require(ServerStorage.Data.Enemies:WaitForChild("Types"))

local Spawning = require(ServerStorage.Game.Systems:WaitForChild("Spawning"))
--local RandomModule = ReplicatedStorage.Game.Shared.Systems:WaitForChild("RandomModule")

local EnemiesHandler = {}
local PlayerSpecificSpawns = {}

function EnemiesHandler.SpawnInArea(spawnArea: BasePart, objectTemplate: Model, count: number, offsetAboveGround: number, exclusiveToPlayer: Player)
	local name = objectTemplate.Name

	if exclusiveToPlayer and PlayerSpecificSpawns[exclusiveToPlayer] then
		PlayerSpecificSpawns[exclusiveToPlayer]:Destroy()
	end

	for i = 1, count do
		local info = EnemyTypes[name]
		
		local ctx = Spawning.SpawnItemInArea(spawnArea, objectTemplate, offsetAboveGround)
		ctx.Model.Humanoid.WalkSpeed = info.WalkSpeed
		ctx.Model.Humanoid.MaxHealth = info.Health
		ctx.Model.Humanoid.Health = info.Health
		ctx.Model.Humanoid.JumpPower = info.JumpPower
		--ctx.Model.Humanoid.AutoJumpEnabled = true
		
		Debris:AddItem(ctx.Model, info.DespawnTime)

		task.spawn(function() info.Control(ctx.Model) end)

		if exclusiveToPlayer then
			PlayerSpecificSpawns[exclusiveToPlayer] = ctx.Model
		end
		
		ctx.Model = workspace
		
		print('[EnemiesHandler] Spawned ' .. name .. ' in ' .. spawnArea.Name)
	end
end

function EnemiesHandler.Start()
	task.spawn(function()
		for enemy, info in pairs(EnemyTypes) do
			for _, spawnArea in pairs(info.SpawnAreas) do
				task.spawn(function()
					while true do
						task.wait(info.SpawnFrequency)
						
						EnemiesHandler.SpawnInArea(spawnArea, info.Model, info.SpawnAmount)		
					end
				end)
			end
		end
	end)
end

function EnemiesHandler.Init()
	print("[EnemiesHandler] Initialised")
end

return EnemiesHandler
