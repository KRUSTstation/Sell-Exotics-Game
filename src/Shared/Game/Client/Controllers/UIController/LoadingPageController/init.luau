local LoadingPageController = {}
LoadingPageController.__index = LoadingPageController

function LoadingPageController.LoadPage(name)
	local page = LoadingPageController.Pages[name]
	if page then
		page.Load(LoadingPageController)
	else
		warn("[LoadingPageController] Page not found: "..name)
	end
end

function LoadingPageController.Init(uicontroller)
	LoadingPageController.Pages = {}
	for _, moduleScript in script:GetDescendants() do
		if moduleScript:IsA("ModuleScript") then
			local module = require(moduleScript)
			LoadingPageController.Pages[moduleScript.Name] = module
		end
	end
	
	print("[LoadingPageController] Initialised")
end

return LoadingPageController