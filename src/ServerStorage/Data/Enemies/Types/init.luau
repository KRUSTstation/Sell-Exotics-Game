local Types = {}

for _, module in script:GetChildren() do
	if module:IsA("ModuleScript") then
		Types[module.Name] = require(module)
	end
end

return Types
