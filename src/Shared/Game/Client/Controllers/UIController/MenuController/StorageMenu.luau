local StorageController = {}
StorageController.__index = StorageController

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.Game.Client:FindFirstChild("Controllers")

local UIController
local DataController = require(Controllers:WaitForChild("DataController"))
local TweenHelper = require(script.Parent:WaitForChild("TweenHelper"))

local RarityLabels = require(ReplicatedStorage.Data.Animals:WaitForChild("RarityLabels"))

local onClickConn

local function GetRarityLabel(animal)
	for rarity, animals in pairs(RarityLabels.Animals) do
		if table.find(animals, animal) then
			return rarity
		end
	end
	return
end

local function ClearGridChildren()
	for _, child in pairs(StorageController.Grid:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

function StorageController.close()
	if UIController.CurrentlyOpenUI == script then UIController.CurrentlyOpenUI = nil end
	
	local t = TweenHelper.MainUITween(StorageController.Frame, false)
	t.Completed:Wait()
	
	StorageController.Frame.Visible = false
	ClearGridChildren()
end

function StorageController.open()
	UIController.CurrentlyOpenUI = script
	local animalInv = DataController.GetAnimalInv()
	StorageController.populate(animalInv)
	
	StorageController.Frame.Visible = true
	TweenHelper.MainUITween(StorageController.Frame, true)
end

function StorageController.populate(items)
	ClearGridChildren()
	
	local templateFolder = ReplicatedStorage.Assets.UI.Templates.Animals.RarityFrames
	
	-- can add a task.spawn for each one for faster rendering if needed
	for animal, animals in pairs(items) do
		for index, info in pairs(animals) do
			local rarity = GetRarityLabel(animal)
			if not rarity then warn('[StorageMenu] No rarityLabel set for '..animal) end
			
			local template = templateFolder:WaitForChild('BackpackAnimalTemplate')
			
			local weight = info.Weight
			local mutations = info.Mutations
			
			local clone = template:Clone()
			
			local animalNameText = clone:WaitForChild("AnimalName")
			animalNameText.Text = animal
			
			local weightText = clone:WaitForChild("Weight")
			weightText.Text = weight..' kg'
			
			local mutationsText = clone:WaitForChild("Mutations")
			mutationsText.Text = "["
			for i, mutation in pairs(mutations) do
				if i ~= #mutations then
					mutationsText.Text = mutationsText.Text..mutation..", "
				else
					mutationsText.Text = mutationsText.Text..mutation.."]"
				end
			end
			
			local favouriteImage = clone:WaitForChild("Favourite")
			local favourite = info.Favourite
			favouriteImage.Image = favourite and "rbxassetid://73379519474717" or "rbxassetid://105792551292840"
			
			local button = favouriteImage:WaitForChild("Button")
			button.MouseButton1Click:Connect(function()
				local favouriteImage = favouriteImage
				
				local animalName = animal
				local Id = info.Id
				
				local data = DataController.GetAnimalInv()
				if not data then return end
				
				local animals = data[animalName]
				
				for _, animal in ipairs(animals) do
					if animal.Id == Id then
						local favourite = not animal.Favourite
						
						DataController.SetAnimalFav(animalName, Id, favourite)
						
						favouriteImage.Image = favourite and "rbxassetid://73379519474717" or "rbxassetid://105792551292840"
						break
					end
				end
			end)
			
			local viewPortFrame = clone:WaitForChild("ViewportFrame")
			local worldModel = viewPortFrame:WaitForChild("WorldModel")
			
			local animalMesh = ReplicatedStorage.Assets.Meshes.Animals:FindFirstChild(animal):Clone()
			animalMesh.Parent = worldModel
			
			local cf, size = animalMesh:GetBoundingBox()

			local targetSize = 8
			local largestDimension = math.max(size.X, size.Y, size.Z)
			local scaleFactor = targetSize / largestDimension

			animalMesh:ScaleTo(scaleFactor)
			animalMesh:PivotTo(CFrame.new(0, 0, 0))
			
			local camera = Instance.new("Camera")
			camera.CFrame = CFrame.new(Vector3.new(0, 2, 10), Vector3.new(0, 0, 0))
			camera.Parent = viewPortFrame
			viewPortFrame.CurrentCamera = camera
			task.spawn(function()
				while viewPortFrame.Parent do
					animalMesh:PivotTo(animalMesh:GetPivot() * CFrame.Angles(0, math.rad(1), 0))
					task.wait(0.01)
				end
			end)
			
			clone.Name = animal .. weight
			clone.Parent = StorageController.Grid
			clone.Background.Image = 'rbxassetid://'..RarityLabels.ImageIds[rarity]
		end
	end
end

function StorageController.Pause()
	if StorageController.Paused then return end
	StorageController.Paused = true
end

function StorageController.Resume()
	if not StorageController.Paused then return end
	StorageController.Paused = false
end

function StorageController.ConnectToggle(func)
	if not func then return end

	StorageController.OnToggle = func
end

function StorageController.RemoveToggle()
	StorageController.OnToggle = nil
end

function StorageController.Init(uiController)
	if not uiController then return end
	
	UIController = uiController
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local ui = gameUI:WaitForChild("Backpack")
	local mainUi = gameUI:WaitForChild("Main")
	
	local frame = ui:WaitForChild("Frame")
	local grid = frame:WaitForChild("Grid")
	local image = frame:WaitForChild("BackGround")
	--local closeButton = frame:WaitForChild("CloseButton")
	local openButton = mainUi.Frame.Menu.Submenu:WaitForChild("StorageButton")
	
	StorageController.Paused = false
	StorageController.OnToggle = nil

	StorageController.UI = ui
	StorageController.Frame = frame
	StorageController.OpenButton = openButton
	--StorageController.CloseButton = closeButton
	StorageController.ImageLabel = image
	StorageController.Grid = grid
	
	StorageController.UI.Frame.Visible = false
	
	if onClickConn then onClickConn:Disconnect() end
	
	onClickConn = StorageController.OpenButton.MouseButton1Click:Connect(function()
		if StorageController.Paused then return end
		if StorageController.OnToggle then StorageController.OnToggle() end
		
		if StorageController.UI.Frame.Visible then
			StorageController.close()
		else
			StorageController.open()
		end
	end)
	
	--StorageController.CloseButton.MouseButton1Click:Connect(function()
	--	StorageController.close()
	--end)
	
	print("[StorageMenuController] StorageMenuController initialised")
end



return StorageController