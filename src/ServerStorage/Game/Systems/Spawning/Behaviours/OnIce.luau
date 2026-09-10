local ModelHelper = require(game:GetService("ServerStorage").Game.Modules:WaitForChild("ModelHelper"))
local CollectionService = game:GetService("CollectionService")

local OnIce = {}

local function IsInTree(trees, pos)
	for _, tree in ipairs(trees:GetChildren()) do
		local cf, size = tree:GetBoundingBox()
		local half = size / 2

		if math.abs(pos.X - cf.Position.X) <= half.X
			and math.abs(pos.Z - cf.Position.Z) <= half.Z then
			return true
		end
	end
	return false
end

local function GetRandomPointOnPart(validParts, part: BasePart)
	if not part:IsA("BasePart") then return end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result

	repeat
		local size = part.Size
		local cf = part.CFrame

		local randomX = (math.random() - 0.5) * size.X
		local randomZ = (math.random() - 0.5) * size.Z

		local origin = (cf * CFrame.new(randomX, 0, randomZ)).Position + Vector3.new(0, 50, 0)
		local direction = Vector3.new(0, -500, 0)

		result = workspace:Raycast(origin, direction, raycastParams)
		
		task.wait()
	until result and result.Instance and table.find(validParts, result.Instance)

	return result.Position
end

function OnIce.Apply(ctx)
	local model = ctx.Model
	local trees = ctx.Trees
	local offset = ctx.OffsetAboveground
	local spawnArea = ctx.SpawnArea
	
	local taggedIce = CollectionService:GetTagged("Ice")
	if #taggedIce == 0 then
		return false
	end
	local validIce = {}
	
	for _, ice in ipairs(taggedIce) do
		if ice:IsDescendantOf(workspace.Places[spawnArea.Name]) then
			table.insert(validIce, ice)
		end
	end
	
	if #validIce == 0 then
		return false
	end
	
	local randomIce = validIce[math.random(1, #validIce)]
	local pos = GetRandomPointOnPart(validIce, randomIce) + Vector3.new(0, offset, 0)
	
	if #validIce == 0 then
		return false
	end
	
	if trees and IsInTree(trees, pos) then
		return false
	end
	
	local angle = math.rad(math.random(0, 360))
	model:PivotTo(CFrame.new(pos) * CFrame.Angles(0, angle, 0))
	ModelHelper.AlignToGround(model)

	return true
end

return OnIce
