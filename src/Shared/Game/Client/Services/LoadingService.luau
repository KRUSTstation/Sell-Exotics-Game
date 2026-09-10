local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LoadingService = {}

local function collect(folder)
	local assets = {}
	for _, inst in ipairs(folder:GetDescendants()) do
		if inst:IsA("Model")
			or inst:IsA("Animation")
			or inst:IsA("Sound")
			or inst:IsA("Decal")
			or inst:IsA("Texture")
			or inst:IsA("ParticleEmitter")
			or inst:IsA("MeshPart")
			or inst:IsA("ImageLabel")
			or inst:IsA("ImageButton") then
			table.insert(assets, inst)
		end
	end
	return assets
end

function LoadingService.LoadAssets(assets: {Instance}, onProgress)
	assert(type(assets) == "table", "LoadAssets expects a table of Instances")
	
	local loaded = 0
	local total = #assets

	local unique = {}
	local finalAssets = {}

	for _, inst in ipairs(assets) do
		if inst and inst:IsDescendantOf(game) then
			if not unique[inst] then
				unique[inst] = true
				table.insert(finalAssets, inst)
			end
		end
	end

	if #finalAssets == 0 then
		return
	end

	ContentProvider:PreloadAsync(finalAssets, function()
		loaded += 1
		if onProgress then
			onProgress(loaded, total)
		end
	end)
end

function LoadingService.LoadAll(onProgress)
	local assets = {}
	
	for _, inst in ipairs(collect(ReplicatedStorage.Assets)) do
		table.insert(assets, inst)
	end
	for _, inst in ipairs(collect(StarterGui)) do
		table.insert(assets, inst)
	end
	
	LoadingService.LoadAssets(assets, onProgress)
	print("[LoadingService] Assets loaded")
	return
end

return LoadingService

