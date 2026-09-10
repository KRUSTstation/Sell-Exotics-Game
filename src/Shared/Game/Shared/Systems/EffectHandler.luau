local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local EffectHandler = {}

function EffectHandler.PlayEffect(effect: string, model: Model)
	if not model.PrimaryPart then
		error(("Model %s must have a PrimaryPart set").format(model.Name))
	end
	
	local effectModel = ReplicatedStorage.Assets.VFX:WaitForChild(effect):Clone()
	effectModel.Anchored = true
	effectModel.CFrame = model.PrimaryPart.CFrame
	effectModel.Parent = workspace

	for _, v in ipairs(effectModel:GetDescendants()) do
		if not (v:IsA("ParticleEmitter") or v:IsA("Beam")) then
			continue
		end

		task.spawn(function()
			local delayTime = v:GetAttribute("EmitDelay") --or 0
			local duration = v:GetAttribute("EmitDuration") --or 0.5

			task.wait(delayTime)
			v.Enabled = true

			if v:IsA("ParticleEmitter") then
				local count = v:GetAttribute("EmitCount") --or 10
				v:Emit(count)
			end

			task.delay(duration, function()
				if v then
					v.Enabled = false
				end
			end)
		end)
	end

	Debris:AddItem(effectModel, 4)
end

function EffectHandler.ParentEffect(model: Model, effectName: string)
	local ppart = model.PrimaryPart
	if not ppart then
		warn(model.Name, "has no PrimaryPart")
		return
	end

	local vfxFolder = ReplicatedStorage.Assets.VFX
	local effectTemplate = vfxFolder:FindFirstChild(effectName)
	if not effectTemplate then
		warn(effectName, "VFX not found")
		return
	end

	local effect = effectTemplate:Clone()
	local cframe, size = model:GetBoundingBox()
	
	effect.Size = size
	effect.Anchored = false
	effect.CFrame = cframe
	effect.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = ppart
	weld.Part1 = effect
	weld.Parent = effect

	return effect
end

return EffectHandler
