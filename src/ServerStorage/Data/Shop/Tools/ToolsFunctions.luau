local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tools = ReplicatedStorage.Assets.Meshes:WaitForChild("Tools")

local ToolsFunctions = {
	["Extending Ladder"] = function(player, tool)
		local ladderTemplate = Tools:WaitForChild("Ladder")
		local char = player.Character
		if not char then return end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		
		if tool then
			tool:Destroy()
		end

		local ladderClone = ladderTemplate:Clone()
		local rootCFrame = root.CFrame
		

		local offset = rootCFrame.LookVector * 10 + Vector3.new(0, 1, 0)
		local rotation = CFrame.Angles(math.rad(-20), 0, 0)

		ladderClone:PivotTo(CFrame.new(rootCFrame.Position + offset) * rotation)
		ladderClone.Parent = workspace

		local backpack = player:FindFirstChild("Backpack")
		
		task.spawn(function()
			local ladder = ladderClone
			task.wait(30)
			
			-- troll explosion
			if ladder.Parent then
				local explosion = Instance.new("Explosion")
				explosion.Parent = workspace
				explosion.Position = (ladder:GetPivot() * CFrame.new(0, -5.5, 0)).Position
				explosion.BlastRadius = 6
				explosion.DestroyJointRadiusPercent = 0
				explosion.Visible = false
				explosion.BlastPressure = 20000000
			end
			
			ladder:Destroy()
		end)
	end,
}

return ToolsFunctions
