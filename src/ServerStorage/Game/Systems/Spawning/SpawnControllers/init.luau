local SpawnControllers = {}

function SpawnControllers.Init()
	for _, module in script:GetChildren() do
		if module:IsA("ModuleScript") then
			SpawnControllers[module.Name] = require(module)
		end
	end
	print("[SpawnControllers] SpawnControllers Initialized")
end

return SpawnControllers
