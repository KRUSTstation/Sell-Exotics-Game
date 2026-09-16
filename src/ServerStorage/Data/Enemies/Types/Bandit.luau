local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PathFinding = require(ServerStorage.Game.Modules:WaitForChild("PathFinding"))

local SpawnAreas = ServerStorage:WaitForChild("SpawnAreas")

local Bandit = {}

Bandit.ActivateDistance = 100
Bandit.DeactivateDistance = 125
Bandit.Health = 100
Bandit.AttackDistance = 5
Bandit.AttackSpeed = 1 -- hits per s
Bandit.Damage = 10

Bandit.JumpPower = 50
Bandit.WalkSpeed = 5 -- not aggro
Bandit.RunSpeed = 12 -- aggroed

Bandit.RoamCdMax = 10
Bandit.RoamCdMin = 5

Bandit.SpawnAreas = {SpawnAreas.Jungle}
Bandit.SpawnFrequency = 500 -- in s
Bandit.SpawnAmount = 10
Bandit.DespawnTime = 100 -- in s

Bandit.Model = ReplicatedStorage.Assets.Meshes.Enemies:WaitForChild("Bandit")

function Bandit.Control(model: Model)
	local attackcd = false
	local aggravated = false
	
	local size = model:GetExtentsSize()
	local path = PathFinding.new(model, {
		AgentRadius = math.max(size.X, size.Z) / 2,
		AgentHeight = size.Y,
		AgentCanJump = true,
		AgentJumpHeight = Bandit.JumpPower,
		AgentCanClimb = true,
		
		Costs = {
			Water = math.huge
		}
	})

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	-- Roaming
	task.spawn(function()
		while model.Parent do
			if not aggravated then
				humanoid.WalkSpeed = Bandit.WalkSpeed

				local toMovePos =
					model:GetPivot().Position
					+ Vector3.new(
						math.random(-10, 10),
						0,
						math.random(-10, 10)
					)

				path:MoveTo(toMovePos)

				while not aggravated and model.Parent do
					if humanoid.MoveDirection.Magnitude == 0 then
						break
					end

					task.wait()
				end

				task.wait(math.random(
					Bandit.RoamCdMin,
					Bandit.RoamCdMax))
			end

			task.wait()
		end
	end)

	while model.Parent do
		for _, player in pairs(Players:GetPlayers()) do
			local char = player.Character
			if not char then
				continue
			end

			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then
				continue
			end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then
				continue
			end

			local distance = (model:GetPivot().Position - hrp.Position).Magnitude

			-- Aggravated
			if distance <= Bandit.ActivateDistance then
				aggravated = true
				humanoid.WalkSpeed = Bandit.RunSpeed

				while distance < Bandit.DeactivateDistance and model.Parent and hum and hum.Health > 0 and hrp do
					path:MoveTo(hrp.Position)

					distance = (model:GetPivot().Position - hrp.Position).Magnitude

					if not attackcd and distance <= Bandit.AttackDistance then
						attackcd = true

						hum:TakeDamage(Bandit.Damage)

						task.delay(
							1 / Bandit.AttackSpeed,
							function()
								attackcd = false
							end)
					end

					task.wait(0.2)
				end

				aggravated = false
			end
		end

		task.wait()
	end
end


return Bandit
