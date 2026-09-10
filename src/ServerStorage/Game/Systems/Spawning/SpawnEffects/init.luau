local SpawnEffects = {}

function SpawnEffects.Init()
	for _, module in script:GetChildren() do
		if module:IsA("ModuleScript") then
			SpawnEffects[module.Name] = require(module)
		end
	end
	print("[SpawnEffects] SpawnEffects Initialized")
end

return SpawnEffects
