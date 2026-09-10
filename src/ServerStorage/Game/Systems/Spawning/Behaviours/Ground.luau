local ModelHelper = require(game:GetService("ServerStorage").Game.Modules:WaitForChild("ModelHelper"))

local Ground = {}

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

function Ground.Apply(ctx)
	local ray = ctx.RaycastResult
	local model = ctx.Model
	local trees = ctx.Trees
	local water = ctx.Water
	local offset = ctx.OffsetAboveGround
	
	if water and ray.Instance:IsDescendantOf(water) then
		return false
	end

	local pos = ray.Position + Vector3.new(0, offset, 0)

	if trees and IsInTree(trees, pos) then
		return false
	end
	
	local angle = math.rad(math.random(0, 360))
	model:PivotTo(CFrame.new(pos) * CFrame.Angles(0, angle, 0))
	ModelHelper.AlignToGround(model)

	return true
end

return Ground
