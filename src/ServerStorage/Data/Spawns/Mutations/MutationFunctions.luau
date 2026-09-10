local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectHandler = require(ReplicatedStorage.Game.Shared.Systems:WaitForChild("EffectHandler"))

local MutationFunctions = {}

MutationFunctions = {
	['Default'] = function(model) return end,

	['Shiny'] = function(ctx)
		local model = ctx.Model
		
		local effect = EffectHandler.ParentEffect(model, 'Shine')
		return
	end,
	
	['Radioactive'] = function(ctx)
		local model = ctx.Model
		
		local effect = EffectHandler.ParentEffect(model, 'Radioactive')
		return
	end,
	
	['Corrupted'] = function(ctx) 
		local model = ctx.Model
		
		local effect = EffectHandler.ParentEffect(model, 'Corrupted')
		local highlight = effect:FindFirstChild("Highlight")
		local clone = highlight:Clone()
		
		clone.Parent = model
		highlight:Destroy()
		return
	end,
	
	['Shocked'] = function(ctx)
		local old = ctx.Model
		local template = game.ReplicatedStorage.Assets.Meshes.Animals.Mutated.Shocked
			:FindFirstChild(old.Name)

		if template then
			local pivot = old:GetPivot()
			local parent = old.Parent
			local scale = old:GetAttribute("Scale") or 1

			local clone = template:Clone()
			clone.Parent = parent
			clone:PivotTo(pivot)
			clone:ScaleTo(scale)

			ctx.Model = clone
			old:Destroy()
		end

		local model = ctx.Model

		EffectHandler.ParentEffect(model, 'Shocked')

		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") and part.Material ~= Enum.Material.Neon then
				part.Material = Enum.Material.Neon
			end
		end
	end,
	
	['Joined'] = function(ctx)
		local model = ctx.Model
		
		local _, size = model:GetBoundingBox()
		
		local clone = model:Clone()
		clone.Parent = model
		clone.Name = "JoinedModel"
		
		local pivot = model:GetPivot()
		clone:PivotTo(pivot * CFrame.new(0, 0, -(size.Z/2 + 0.05)))
		return
	end,
}

return MutationFunctions
