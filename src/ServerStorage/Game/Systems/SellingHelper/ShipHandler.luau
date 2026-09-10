local ShipHandler = {}

local ship = workspace.SpawnArea:WaitForChild('Ship')

local function WeldShip()
	local model = ship

	if not model.PrimaryPart then
		warn("Model '" .. model.Name .. "' does not have a PrimaryPart set")
		return
	end

	local primaryPart = model.PrimaryPart

	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part ~= primaryPart then
			local motor = Instance.new("Motor6D")
			motor.Name = part.Name .. "Motor"
			motor.Part0 = primaryPart
			motor.Part1 = part

			motor.C0 = primaryPart.CFrame:Inverse() * part.CFrame
			motor.C1 = CFrame.new()

			motor.Parent = primaryPart

			part.Anchored = false
		end
	end

	primaryPart.Anchored = true
end

function ShipHandler.Init()
	WeldShip()
	print("[ShipHandler] ShipHandler initialization complete.")
end

return ShipHandler
