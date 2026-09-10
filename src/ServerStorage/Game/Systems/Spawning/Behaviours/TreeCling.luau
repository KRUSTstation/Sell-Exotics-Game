local TreeCling = {}

local CollectionService = game:GetService("CollectionService")

local MAX_SURFACE_Y = 0.35
local RANDOM_ATTEMPTS = 6

local function randomSurfacePoint(part)
	local cf = part.CFrame
	local half = part.Size * 0.5

	local face = math.random(4)
	local localPoint

	if face == 1 then
		localPoint = Vector3.new( half.X, math.random(-half.Y, half.Y), math.random(-half.Z, half.Z))
	elseif face == 2 then
		localPoint = Vector3.new(-half.X, math.random(-half.Y, half.Y), math.random(-half.Z, half.Z))
	elseif face == 3 then
		localPoint = Vector3.new(math.random(-half.X, half.X), math.random(-half.Y, half.Y),  half.Z)
	else
		localPoint = Vector3.new(math.random(-half.X, half.X), math.random(-half.Y, half.Y), -half.Z)
	end

	return cf:PointToWorldSpace(localPoint)
end

local function raycastIntoPart(point, part)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { part }
	params.IgnoreWater = true

	local dir = (part.Position - point)
	if dir.Magnitude < 0.01 then
		dir = -part.CFrame.LookVector
	end

	return workspace:Raycast(point, dir.Unit * 6, params)
end

local function getClingCFrame(hitPos, normal, offset, modelFrontOffsetCFrame)
	local forward = -normal

	local right = Vector3.yAxis:Cross(forward)
	if right.Magnitude < 0.05 then
		right = Vector3.xAxis
	end
	local up = forward:Cross(right)

	local baseCF = CFrame.fromMatrix(hitPos + normal * offset, right.Unit, up.Unit, forward.Unit)

	if modelFrontOffsetCFrame then
		return baseCF * modelFrontOffsetCFrame
	end

	return baseCF
end

local function getModelRadius(model)
	local size = Vector3.zero
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			size = Vector3.new(
				math.max(size.X, part.Size.X),
				math.max(size.Y, part.Size.Y),
				math.max(size.Z, part.Size.Z)
			)
		end
	end
	return size.Magnitude / 2
end

function TreeCling.Apply(ctx)
	local model = ctx.Model
	local root = model and model.PrimaryPart
	local treesFolder = ctx.Trees

	if not model or not root or not treesFolder then
		return false
	end

	local taggedTrunks = CollectionService:GetTagged("TreeTrunk")
	if #taggedTrunks == 0 then
		return false
	end

	local modelRadius = getModelRadius(model)

	for _ = 1, RANDOM_ATTEMPTS do
		local trunk = taggedTrunks[math.random(#taggedTrunks)]

		if trunk:IsDescendantOf(treesFolder) then
			local surfacePoint = randomSurfacePoint(trunk)
			local hit = raycastIntoPart(surfacePoint, trunk)

			if hit and math.abs(hit.Normal.Y) <= MAX_SURFACE_Y then
				local frontOffset = CFrame.Angles(0, math.rad(90), 0)

				local cf = getClingCFrame(hit.Position, hit.Normal, modelRadius, frontOffset)
				model:PivotTo(cf)

				model:PivotTo(cf)
				return true
			end
		end
	end

	return false
end

return TreeCling
