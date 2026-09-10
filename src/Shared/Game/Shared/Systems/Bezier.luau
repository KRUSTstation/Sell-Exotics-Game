local RunService = game:GetService("RunService")

local Bezier = {}
Bezier.__index = Bezier

local function QuadraticBezFunc(t: number, P0: Vector3, P1: Vector3, P2: Vector3)
	return (1-t)^2 * P0 + 2 * (1-t) * t * P1 + t^2 * P2
end

function Bezier.new(P0: Vector3, P1: Vector3, P2: Vector3, duration: number, part: Part)
	local self = setmetatable({}, Bezier)
	self.P0, self.P1, self.P2 = P0, P1, P2
	self.Duration = duration
	self.Part = part
	self.t = 0
	return self
end

function Bezier:Play(onComplete: () -> ())
	self.t = 0
	self.Connection = RunService.PreRender:Connect(function(dt)
		self.t += dt / self.Duration
		self.t = math.clamp(self.t, 0, 1)

		local Pos = QuadraticBezFunc(self.t, self.P0, self.P1, self.P2)
		if self.Part then
			self.Part.Position = Pos
		end

		if self.t >= 1 then
			self.Connection:Disconnect()
			self.Connection = nil
			if onComplete then onComplete() end
		end
	end)
end

function Bezier:Stop()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end
end

local CubicBezier = setmetatable({}, {__index = Bezier})
CubicBezier.__index = CubicBezier

local function CubicBezFunc(t: number, P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3)
	return (1-t)^3 * P0
		+ 3 * (1-t)^2 * t * P1
		+ 3 * (1-t) * t^2 * P2
		+ t^3 * P3
end

function CubicBezier.new(P0: Vector3, P1: Vector3, P2: Vector3, P3: Vector3, duration: number, part: Part)
	local self = setmetatable(Bezier.new(P0, P1, P2, duration, part), CubicBezier)
	self.P3 = P3
	return self
end

function CubicBezier:Play(onComplete: () -> ())
	self.t = 0
	self.Connection = RunService.PreRender:Connect(function(dt)
		self.t += dt / self.Duration
		self.t = math.clamp(self.t, 0, 1)

		local Pos = CubicBezFunc(self.t, self.P0, self.P1, self.P2, self.P3)
		if self.Part then
			self.Part.Position = Pos
		end

		if self.t >= 1 then
			self.Connection:Disconnect()
			self.Connection = nil
			if onComplete then onComplete() end
		end
	end)
end

return {
	Quadratic = Bezier,
	Cubic = CubicBezier
}
