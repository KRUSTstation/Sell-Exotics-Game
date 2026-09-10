local Behaviours = {}

function Behaviours.Init()
	for _, module in script:GetChildren() do
		if module:IsA("ModuleScript") then
			Behaviours[module.Name] = require(module)
		end
	end
	print("[Behaviours] Behaviours Initialized")
end

return Behaviours
