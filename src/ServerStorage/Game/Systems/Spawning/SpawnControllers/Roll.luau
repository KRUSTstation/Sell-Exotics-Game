local RunService = game:GetService("RunService")
local ModelHelper = require(game:GetService("ServerStorage").Game.Modules:WaitForChild("ModelHelper"))

local Roll = {}

local function GetRandomGroundPoint(origin, radius, model)
	local waterFolder = workspace:FindFirstChild("Water")

	local offset = Vector3.new(
		math.random(-radius, radius),
		0,
		math.random(-radius, radius)
	)

	local rayOrigin = origin + offset + Vector3.new(0, 50, 0)
	local rayDirection = Vector3.new(0, -200, 0)

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {model}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(rayOrigin, rayDirection, params)

	if result then
		if waterFolder and result.Instance:IsDescendantOf(waterFolder) then
			return nil
		end
		return result.Position
	end
end

function Roll.Control(ctx)
	local model = ctx.Model
	local params = ctx.SpawnInfoData.Roll

	local speed = params.Speed
	local wanderRadius = params.Radius
	local delayTime = params.DelayTime

	task.spawn(function()
		while model and model.PrimaryPart do
			local startCF = model:GetPivot()
			local target = GetRandomGroundPoint(startCF.Position, wanderRadius, model)

			if target then
				local primary = model.PrimaryPart
				local rollRadius = math.max(primary.Size.X, primary.Size.Z) / 2

				local cf = model:GetPivot()
				local pos = cf.Position
				local dir = (Vector3.new(target.X, 0, target.Z) - Vector3.new(pos.X, 0, pos.Z)).Unit

				model:PivotTo(CFrame.lookAt(pos, pos + dir))
				local rollAxis = model:GetPivot().RightVector

				while model and model.PrimaryPart do
					local dt = RunService.Heartbeat:Wait()
					if not model.PrimaryPart then
						break
					end
					
					local currentCF = model:GetPivot()
					local pos = currentCF.Position

					local toTarget = Vector3.new(target.X, 0, target.Z) - Vector3.new(pos.X, 0, pos.Z)
					local dist = toTarget.Magnitude
					if dist < 2 then break end

					local direction = toTarget.Unit
					local moveDistance = speed * dt
					local moveVector = direction * moveDistance
					local newPos = pos + moveVector

					local ray = workspace:Raycast(newPos + Vector3.new(0,5,0), Vector3.new(0,-20,0))
					local normal = ray and ray.Normal or Vector3.yAxis

					local rollAxis = direction:Cross(normal).Unit

					local rollRadius = math.max(model.PrimaryPart.Size.X, model.PrimaryPart.Size.Z) / 2
					local rotationAmount = moveDistance / rollRadius

					local newCF =
						CFrame.new(newPos) *
						(currentCF - pos) *
						CFrame.fromAxisAngle(rollAxis, rotationAmount)

					model:PivotTo(newCF)
					ModelHelper.AlignToGround(model)
				end
			else
				task.wait()
			end

			task.wait(math.random(delayTime.Min, delayTime.Max))
		end
	end)
end

return Roll