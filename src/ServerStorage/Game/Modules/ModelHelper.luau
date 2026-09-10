local ModelHelper = {}

function ModelHelper.GetLowestPoint(model)
	local lowestY = math.huge

	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("BasePart") then
			local cf = obj.CFrame
			local size = obj.Size

			for x = -1, 1, 2 do
				for y = -1, 1, 2 do
					for z = -1, 1, 2 do
						local corner = cf * Vector3.new(
							size.X/2 * x,
							size.Y/2 * y,
							size.Z/2 * z
						)
						lowestY = math.min(lowestY, corner.Y)
					end
				end
			end
		end
	end

	return lowestY
end

function ModelHelper.AlignToGround(model)
	local primary = model.PrimaryPart
	if not primary then return end

	local origin = primary.Position + Vector3.new(0, 10, 0)
	local direction = Vector3.new(0, -50, 0)

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {model}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction, params)

	if result then
		local groundY = result.Position.Y

		local currentCF = model:GetPivot()
		local currentLowest = ModelHelper.GetLowestPoint(model)

		local delta = groundY - currentLowest

		model:PivotTo(currentCF + Vector3.new(0, delta, 0))
	end
end

return ModelHelper
