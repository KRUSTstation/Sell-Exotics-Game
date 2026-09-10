local Players = game:GetService("Players")

local playerCds = {}
local DAMAGE = 10
local COOLDOWN = 1

local function onTouched(hit)
	local character = hit.Parent
	local humanoid = character and character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	if playerCds[player] then return end
	playerCds[player] = true

	humanoid:TakeDamage(DAMAGE)

	task.delay(COOLDOWN, function()
		playerCds[player] = nil
	end)
end

for _, sign in pairs(workspace.Signs:GetChildren()) do
	for _, kbrick in pairs(sign:GetChildren()) do
		if kbrick.Name == "KillBrick" and kbrick:IsA("BasePart") then
			kbrick.Touched:Connect(onTouched)
		end
	end
end
