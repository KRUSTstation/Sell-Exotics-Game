local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathFindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local TableHelper = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("TableHelper"))

local SHOW_DEBUG_PATH = false -- turn off when yes
local MAX_STUCK_TIME = 1.5
local MAX_STUCK_SPEED = 2

local PRESET_PARAMS = {
	Costs = {
		StuckArea = math.huge
	}
}

local PathFinding = {}
PathFinding.__index = PathFinding

function PathFinding.new(model: Model, params: {})
	local self = setmetatable({}, PathFinding)
	
	params = TableHelper.MergeDict(params or {}, PRESET_PARAMS)
	
	self.path = PathFindingService:CreatePath(params)
	self.model = model
	
	self.idle = true
	self.moving = nil
	self.lastTarget = nil
	
	self.params = params
	
	if not self.model:FindFirstChildOfClass("Humanoid") then
		warn("No humanoid found in model: " .. self.model.Name .. ". Pathfinding will not work.")
		return
	end
	
	return self
end

function PathFinding:VisualizePath(waypoints)
	if not SHOW_DEBUG_PATH then
		return
	end

	if self.debugFolder then
		self.debugFolder:Destroy()
	end

	self.debugFolder = Instance.new("Folder")
	self.debugFolder.Name = "PathDebug_" .. self.model.Name
	self.debugFolder.Parent = workspace

	for i, waypoint in waypoints do
		local part = Instance.new("Part")
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(0.6, 0.6, 0.6)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Material = Enum.Material.Neon

		if waypoint.Action == Enum.PathWaypointAction.Jump then
			part.Color = Color3.new(1, 0, 0)
		else
			part.Color = Color3.new(0, 1, 0)
		end

		part.Position = waypoint.Position
		part.Parent = self.debugFolder

		local label = Instance.new("BillboardGui")
		label.Size = UDim2.new(0, 40, 0, 20)
		label.AlwaysOnTop = true
		label.Parent = part

		local text = Instance.new("TextLabel")
		text.Size = UDim2.new(1, 0, 1, 0)
		text.BackgroundTransparency = 1
		text.TextColor3 = Color3.new(1, 1, 1)
		text.Text = tostring(i)
		text.Parent = label
	end
end

function PathFinding:MoveTo(pos: Vector3)
	local humanoid = self.model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false
	end
	
	humanoid.UseJumpPower = true
	--humanoid.AutoJumpEnabled = true

	if self.lastTarget and (self.lastTarget - pos).Magnitude < 4 then
		return self.moving ~= nil
	end

	if self.moving then
		coroutine.close(self.moving)
		self.moving = nil
		self.idle = true
	end

	self.lastTarget = pos

	self.moving = coroutine.create(function()
		self.idle = false

		while true do
			local remap = false
			
			self.path:ComputeAsync(self.model:GetPivot().Position, pos)

			if self.path.Status ~= Enum.PathStatus.Success then
				return false
			end
			
			local waypoints = self.path:GetWaypoints()
			self:VisualizePath(waypoints)

			for i, waypoint in waypoints do
				if not self.model.Parent then
					return false
				end

				if waypoint.Action == Enum.PathWaypointAction.Jump then
					local currentY = self.model:GetPivot().Position.Y

					if waypoint.Position.Y > currentY + 1 then		
						humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
						humanoid.Jump = true
					end
				end

				humanoid:MoveTo(waypoint.Position)

				local reachedSignal = humanoid.MoveToFinished
				local reached = false

				local conn
				conn = reachedSignal:Connect(function(r)
					reached = r
				end)

				local initialPos = self.model:GetPivot().Position
				local initialTime = tick()

				local stuckIniTime = nil

				while not reached do
					local newPos = self.model:GetPivot().Position
					local dist = (newPos - waypoint.Position).Magnitude

					local speed = (newPos - initialPos).Magnitude / (tick() - initialTime)

					if speed > MAX_STUCK_SPEED then
						stuckIniTime = tick()
					end

					if stuckIniTime and (tick() - stuckIniTime) >= MAX_STUCK_TIME then
						remap = true
						break
					end

					initialPos = newPos
					initialTime = tick()

					if dist <= self.params.AgentRadius + 2 then
						reached = true
						break
					end
					task.wait()
				end

				conn:Disconnect()
				
				if remap then
					break
				end

				if not reached then
					return false
				end
			end
			
			if not remap then
				break
			end
		end

		self.idle = true
		self.moving = nil
		self.lastTarget = nil

		return true
	end)

	local success = coroutine.resume(self.moving)

	return success
end

return PathFinding
