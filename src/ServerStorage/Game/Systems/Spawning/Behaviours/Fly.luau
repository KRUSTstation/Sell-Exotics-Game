local Fly = {}

function Fly.Apply(ctx)
	local ray = ctx.RaycastResult
	local data = ctx.SpawnInfoData
	local spawnArea = ctx.SpawnArea

	local flyData = data.Fly
	if not flyData then
		return false
	end

	if math.random(1, flyData.Chance) ~= 1 then
		return false
	end

	local template = game.ReplicatedStorage.Assets.Meshes.Animals:FindFirstChild(ctx.Model.Name .. "_Flying")
	if not template then
		warn("Missing flying variant for", ctx.Model.Name)
		return false
	end

	local newModel = template:Clone()
	newModel.Parent = ctx.Model.Parent
	
	for name, value in pairs(ctx.Model:GetAttributes()) do
		newModel:SetAttribute(name, value)
	end

	ctx.Model:Destroy()
	ctx.Model = newModel

	local flyHeight = math.random(flyData.MinAltitude, flyData.MaxAltitude)
	local desiredPos = ray.Position + Vector3.new(0, flyHeight, 0)

	local extentsY = newModel:GetExtentsSize().Y
	local clearance = (extentsY / 2) + 1

	local upParams = RaycastParams.new()
	upParams.FilterDescendantsInstances = {spawnArea, newModel.Parent}
	upParams.FilterType = Enum.RaycastFilterType.Exclude

	local upResult = workspace:Raycast(
		ray.Position + Vector3.new(0, clearance, 0),
		Vector3.new(0, flyHeight, 0),
		upParams
	)

	if upResult then
		desiredPos = upResult.Position - Vector3.new(0, clearance, 0)
	end
	
	local angle = math.rad(math.random(0, 360))
	newModel:PivotTo(CFrame.new(desiredPos) * CFrame.Angles(0, angle, 0))
	return true
end

return Fly
