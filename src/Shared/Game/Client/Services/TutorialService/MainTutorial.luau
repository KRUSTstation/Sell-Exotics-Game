local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")
local tutorialUI = playerGui.GameUI:WaitForChild("Tutorials")

local MainTutUI = ReplicatedStorage.Assets.UI.Tutorial.MainTutorial
local sellingPrompt = workspace.SpawnArea.Ship:WaitForChild("Sell"):WaitForChild("ProximityPrompt")

local ship = workspace:WaitForChild("SpawnArea"):WaitForChild("Ship")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local SpawnDummyEvent = Remotes.SpawningEvents:WaitForChild("SpawnDummy")

local MainTutorial = {}
local UIStates = {}

for _, frame in pairs(MainTutUI:GetChildren()) do
	if frame:IsA("Frame") then
		UIStates[frame.Name] = {
			Position = frame.Position
		}
	end
end

function MainTutorial.OpenFrame()
	if MainTutorial.Open then return end
	
	local mainTutorialUI = tutorialUI:FindFirstChild("MainTutorialFrame")
	local openTutorialUI = tutorialUI:FindFirstChild("OpenTutorialFrame")

	if mainTutorialUI and openTutorialUI then
		MainTutorial.Open = true
		
		mainTutorialUI.Position = UDim2.new(UIStates[mainTutorialUI.Name].Position.X.Scale, 0, 1, 0)
		mainTutorialUI.Visible = true
		
		local t = TweenService:Create(mainTutorialUI, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UIStates[mainTutorialUI.Name].Position})
		t:Play()
		ReplicatedStorage.Assets.SFX.UI:WaitForChild("Swipe1"):Play()
		
		local t = TweenService:Create(openTutorialUI, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(UIStates[openTutorialUI.Name].Position.X.Scale, 0, 1, 0)})
		t:Play()
		t.Completed:Wait()
		openTutorialUI.Visible = false
	end
end

function MainTutorial.CloseFrame()
	if not MainTutorial.Open then return end
	
	local mainTutorialUI = tutorialUI:FindFirstChild("MainTutorialFrame")
	local openTutorialUI = tutorialUI:FindFirstChild("OpenTutorialFrame")
	
	if mainTutorialUI and openTutorialUI then
		MainTutorial.Open = false
		
		local t = TweenService:Create(mainTutorialUI, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(UIStates[mainTutorialUI.Name].Position.X.Scale, 0, 1, 0)})
		t:Play()
		ReplicatedStorage.Assets.SFX.UI:WaitForChild("Swipe1"):Play()
		t.Completed:Wait()
		
		mainTutorialUI.Visible = false
		
		openTutorialUI.Position = UDim2.new(openTutorialUI.Position.X.Scale, 0, 1, 0)
		local t = TweenService:Create(openTutorialUI, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(UIStates[openTutorialUI.Name].Position.X.Scale, 0, 0.95, 0)})
		openTutorialUI.Visible = true
		t:Play()	
	end
end

local function getCameraCFrame(target, dist, fov)
	fov = fov or 70

	local cf, size

	if target:IsA("Model") then
		cf, size = target:GetBoundingBox()
	elseif target:IsA("BasePart") then
		cf = target.CFrame
		size = target.Size
	else
		error("Target must be a Model or BasePart")
	end

	local center = cf.Position
	local maxSize = math.max(size.X, size.Y, size.Z)

	local distance = (maxSize / 2) / math.tan(math.rad(fov / 2))

	distance = distance * dist

	local direction = Vector3.new(1, 1, 1).Unit

	local cameraPosition = center + direction * distance

	return CFrame.new(cameraPosition, center)
end

local function waitForPrompt(prompt)
	while true do
		local triggered = false

		local conn
		conn = prompt.Triggered:Connect(function(plr)
			if plr == player then
				triggered = true
			end
		end)

		repeat task.wait() until triggered or not player.Character

		conn:Disconnect()

		if triggered then
			return
		end

		player.CharacterAdded:Wait()
	end
end

function MainTutorial.StartTutorial()
	local char = player.Character or player.CharacterAdded:Wait()
	
	local mainTutorialUI = MainTutUI:WaitForChild("MainTutorialFrame"):Clone()
	local collectAnimalUI = MainTutUI:WaitForChild("CollectAnimalFrame"):Clone()
	local sellItemUI = MainTutUI:WaitForChild("SellItemFrame"):Clone()
	local openTutorialUI = MainTutUI:WaitForChild("OpenTutorialFrame"):Clone()
	
	player.CharacterAdded:Connect(function(newChar)
		camera.CameraType = Enum.CameraType.Custom
		tutorialUI = playerGui.GameUI:WaitForChild("Tutorials")
		openTutorialUI = MainTutUI:WaitForChild("OpenTutorialFrame"):Clone()

		openTutorialUI.Parent = tutorialUI
		openTutorialUI.Visible = not MainTutorial.Open
		openTutorialUI.Button.MouseButton1Click:Connect(MainTutorial.OpenFrame)
		
		char = newChar
	end)
	
	mainTutorialUI.Parent = tutorialUI
	
	openTutorialUI.Parent = tutorialUI
	openTutorialUI.Visible = not MainTutorial.Open
	openTutorialUI.Button.MouseButton1Click:Connect(MainTutorial.OpenFrame)
	
	MainTutorial.OpenFrame()
	local closeConn = mainTutorialUI:WaitForChild("Close").MouseButton1Click:Connect(MainTutorial.CloseFrame)
	
	collectAnimalUI.Parent = mainTutorialUI
	collectAnimalUI.Visible = true
	
	SpawnDummyEvent:FireServer()
	task.wait(0.5)
	
	local model
	while not model do
		for _, i in pairs(workspace.Spawns:GetDescendants()) do
			local att = i:GetAttribute("ExclusiveToPlayer")
			
			if att and att == Players.LocalPlayer.UserId then
				model = i
				break
			end
			task.wait()
		end
	end
	
	local showMeWherecd = false
	local function showMeWhere(model, dist)
		if showMeWherecd then return end
		showMeWherecd = true

		camera.CameraType = Enum.CameraType.Scriptable
		local camCFrame = getCameraCFrame(model, dist)
		local t = TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = camCFrame})

		MainTutorial.CloseFrame()
		t:Play()
		t.Completed:Wait()
		task.wait(3)

		local hrp = char:WaitForChild("HumanoidRootPart")
		local offset = Vector3.new(0, 2, 8)
		local cameraPosition = hrp.Position + hrp.CFrame:VectorToWorldSpace(offset)

		local returnCFrame = CFrame.new(cameraPosition, hrp.Position)

		local t = TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = returnCFrame})
		t:Play()
		t.Completed:Wait()

		camera.CameraType = Enum.CameraType.Custom
		MainTutorial.OpenFrame()

		showMeWherecd = false
	end
	
	local showMeWhereConn = collectAnimalUI:WaitForChild("ShowMeWhere").MouseButton1Click:Connect(function()
		showMeWhere(model, 20)
	end)
	
	local highlight = Instance.new("Highlight")
	highlight.Parent = workspace
	highlight.Adornee = model
	
	local modelPrompt = model.PrimaryPart:WaitForChild("ProximityPrompt")
	waitForPrompt(modelPrompt)
	
	showMeWhereConn:Disconnect()
	
	if not mainTutorialUI or not mainTutorialUI.Parent then	
		closeConn:Disconnect()
		
		mainTutorialUI = MainTutUI:WaitForChild("MainTutorialFrame"):Clone()
		sellItemUI = MainTutUI:WaitForChild("SellItemFrame"):Clone()
		openTutorialUI = MainTutUI:WaitForChild("OpenTutorialFrame"):Clone()
		
		mainTutorialUI.Parent = tutorialUI

		closeConn = mainTutorialUI:WaitForChild("Close").MouseButton1Click:Connect(MainTutorial.CloseFrame)
	end
	
	collectAnimalUI:Destroy()
	sellItemUI.Parent = mainTutorialUI
	sellItemUI.Visible = true
	MainTutorial.OpenFrame()
	
	local showMeWhereConn = sellItemUI:WaitForChild("ShowMeWhere").MouseButton1Click:Connect(function()
		showMeWhere(ship, 1)
	end)
	
	highlight.Adornee = sellingPrompt.Parent.Parent
	
	waitForPrompt(sellingPrompt)
	
	highlight:Destroy()
	
	closeConn:Disconnect()
	MainTutorial.CloseFrame()
	showMeWhereConn:Disconnect()
	mainTutorialUI:Destroy()
	openTutorialUI:Destroy()
	
	return 'completed'
end

return MainTutorial
