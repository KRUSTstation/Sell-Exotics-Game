local WaterHandler = {}

function WaterHandler.Init()
	local waterModel = workspace:WaitForChild("Water")
	
	for _, part in ipairs(waterModel:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(function(part)
				local char = part.Parent
				if char:FindFirstChild("Humanoid") then
					char.Humanoid.Health = 0
				end
			end)
		end
	end
	
	print("[WaterHandler] WaterHandler initialized")																							
end

return WaterHandler
