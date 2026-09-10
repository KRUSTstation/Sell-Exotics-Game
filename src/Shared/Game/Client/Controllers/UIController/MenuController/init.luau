local MenuController = {}
MenuController.__index = MenuController

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local UserInputService = game:GetService("UserInputService")

local isTouch = UserInputService.TouchEnabled

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controllers = ReplicatedStorage.Game.Client:FindFirstChild("Controllers")

local SFX = ReplicatedStorage.Assets.SFX.UI

local UIController
local DataController = require(Controllers:WaitForChild("DataController"))

local cd = false

local hoverCount = 0

local hoverEnterConn
local hoverLeaveConn

local tweenOutTime = 0.2
local tweenInTime = 0.2
local hoverAreaPadding = 50

local buttons = {}
local statOriginals = {}
local buttonOriginals = {}

local hoverTweens = {}
local hoverSizes = {}

local total

local radius

local function getAngleRange()
	return -65, 65
end

local function updateRadius()
	local cam = workspace.CurrentCamera
	radius = math.clamp(cam.ViewportSize.Y * 0.18, 120, 260)
end

local function getRadius()
	return 0.18
end

local function getContainerCenter()
	local button = MenuController.OpenButton

	local absPos = button.AbsolutePosition
	local absSize = button.AbsoluteSize

	return absPos + (absSize * 0.5)
end

local function centerToLocal(centerPos)
	local frame = MenuController.mainUI
	local frameAbsPos = frame.AbsolutePosition
	local frameAbsSize = frame.AbsoluteSize

	local relative = centerPos - frameAbsPos

	return UDim2.fromScale(
		relative.X / frameAbsSize.X,
		relative.Y / frameAbsSize.Y
	)
end

local function resetToStart(btn)
	local center = getContainerCenter()
	btn.Position = centerToLocal(center)
	btn.Visible = false
end

local function calculateFinalPositions()
	local positions = {}

	local centerOffset = centerToLocal(getContainerCenter())
	local centerX = centerOffset.X.Scale
	local centerY = centerOffset.Y.Scale

	local radius = getRadius()
	local startAngle, endAngle = getAngleRange()

	local cam = workspace.CurrentCamera
	local aspect = cam.ViewportSize.X / cam.ViewportSize.Y

	for i, btn in ipairs(buttons) do
		local t = (i - 1) / math.max(1, total - 1)
		local angle = math.rad(startAngle + (endAngle - startAngle) * t)

		local x = math.cos(angle) * radius / aspect
		local y = math.sin(angle) * radius

		positions[btn] = UDim2.fromScale(
			centerX + x,
			centerY - y
		)
	end

	return positions
end

local function updateHoverArea()
	if not MenuController.OpenButton or not MenuController.HoverArea then
		return
	end

	local btn = MenuController.OpenButton
	local p = btn.AbsolutePosition
	local s = btn.AbsoluteSize
	local frame = MenuController.HoverArea
	local parentPos = frame.Parent.Parent.AbsolutePosition

	if not MenuController.isOpen then
		frame.Size = UDim2.fromOffset(s.X + hoverAreaPadding * 2, s.Y + hoverAreaPadding * 2)
		frame.Position = UDim2.fromOffset(
			(p.X + s.X / 2) - parentPos.X,
			(p.Y + s.Y / 2) - parentPos.Y
		)
		return
	end

	local center = getContainerCenter()
	local startAngle, endAngle = getAngleRange()
	updateRadius()

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge

	for i = 1, total do
		local t = (i - 1) / math.max(1, total - 1)
		local angle = math.rad(startAngle + (endAngle - startAngle) * t)
		
		local x = math.cos(angle) * radius
		local y = math.sin(angle) * radius

		local pos = center + Vector2.new(x, -y)

		minX = math.min(minX, pos.X)
		minY = math.min(minY, pos.Y)
		maxX = math.max(maxX, pos.X)
		maxY = math.max(maxY, pos.Y)
	end

	minX = math.min(minX, p.X)
	minY = math.min(minY, p.Y)
	maxX = math.max(maxX, p.X + s.X)
	maxY = math.max(maxY, p.Y + s.Y)

	minX -= hoverAreaPadding
	minY -= hoverAreaPadding
	maxX += hoverAreaPadding
	maxY += hoverAreaPadding

	local size = Vector2.new(maxX - minX, maxY - minY)
	local centerVec = Vector2.new(minX + size.X / 2, minY + size.Y / 2)

	frame.Size = UDim2.fromOffset(size.X, size.Y)
	frame.Position = UDim2.fromOffset(
		centerVec.X - parentPos.X,
		centerVec.Y - parentPos.Y
	)
end

local function toggleSubmenu()
	if not MenuController.OpenButton or not MenuController.mainUI then
		return
	end
	
	updateRadius()
	updateHoverArea()
	
	MenuController.isOpen = not MenuController.isOpen
	
	if MenuController.isOpen then
		updateHoverArea()
	end
	
	local tween

	local finalPositions = calculateFinalPositions()
	local center = getContainerCenter()
	
	if not buttonOriginals[MenuController.OpenButton] then
		buttonOriginals[MenuController.OpenButton] = {
			position = MenuController.OpenButton.Position,
			size = MenuController.OpenButton.Size,
		}
	end
	
	if MenuController.isOpen then
		TweenService:Create(MenuController.OpenButton, TweenInfo.new(tweenInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.15, 0, 0.15, 0)}):Play()
	else
		TweenService:Create(MenuController.OpenButton, TweenInfo.new(tweenInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = buttonOriginals[MenuController.OpenButton].size, }):Play()
	end

	for _, btn in ipairs(buttons) do
		if MenuController.isOpen then
			btn.Visible = true
			
			tween = TweenService:Create(
				btn,
				TweenInfo.new(tweenInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = finalPositions[btn] }
			)
				
			tween:Play()
		else
			tween = TweenService:Create(
				btn,
				TweenInfo.new(tweenOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = centerToLocal(center) }
			)
			
			tween:Play()
			task.delay(tweenOutTime, function()
				if not MenuController.isOpen then
					btn.Visible = false
				end
			end)
		end
		task.wait(0.04)
	end

	local tween1
	
	for _, stat in pairs(MenuController.StatsFolder:GetChildren()) do	
		local label = stat:WaitForChild("Label")
		local amount = stat:WaitForChild("Amount")
		
		if not statOriginals[stat] then
			statOriginals[stat] = {
				position = stat.Position,
				size = amount.Size,
			}
		end
		
		local tween2
		
		if MenuController.isOpen then
			tween1 = TweenService:Create(amount, TweenInfo.new(tweenInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.05, 0, amount.Size.Y.Scale, amount.Size.Y.Offset)})
			tween2 = TweenService:Create(stat, TweenInfo.new(tweenInTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.01, 0, stat.Position.Y.Scale, stat.Position.Y.Offset)})
		else
			tween1 = TweenService:Create(amount, TweenInfo.new(tweenOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = statOriginals[stat].size})
			tween2 = TweenService:Create(stat, TweenInfo.new(tweenOutTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = statOriginals[stat].position})
			--amount.Visible = true
		end
		tween1:Play()
		tween2:Play()
	end
	
	updateHoverArea()
	
	if tween1 and tween1.PlaybackState == Enum.PlaybackState.Playing then
		tween1.Completed:Wait()
	end
	
	for _, stat in pairs(MenuController.StatsFolder:GetChildren()) do		
		local amount = stat:WaitForChild("Amount")

		--amount.Visible = not MenuController.isOpen
	end
	
	if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
		tween.Completed:Wait()
	end
end

local function setAnchorPreservePosition(gui, newAnchor)
	local absPos = gui.AbsolutePosition
	local absSize = gui.AbsoluteSize
	local oldAnchor = gui.AnchorPoint

	gui.AnchorPoint = newAnchor

	local delta = (newAnchor - oldAnchor) * absSize

	gui.Position = UDim2.fromOffset(
		absPos.X + delta.X,
		absPos.Y + delta.Y
	)
end

local HOVER_SCALE = 1.2
local HOVER_TIME = 0.12

local function onButtonHover(btn)
	if not hoverSizes[btn] then
		hoverSizes[btn] = UDim2.fromScale(btn.Size.X.Scale, btn.Size.Y.Scale)
	end

	if hoverTweens[btn] then
		hoverTweens[btn]:Cancel()
	end

	local original = hoverSizes[btn]

	hoverTweens[btn] = TweenService:Create(
		btn,
		TweenInfo.new(HOVER_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = UDim2.fromScale(
				original.X.Scale * HOVER_SCALE,
				original.Y.Scale * HOVER_SCALE
			)
		}
	)

	hoverTweens[btn]:Play()
end

local function onButtonLeave(btn)
	if not hoverSizes[btn] then return end

	if hoverTweens[btn] then
		hoverTweens[btn]:Cancel()
	end

	hoverTweens[btn] = TweenService:Create(
		btn,
		TweenInfo.new(HOVER_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Size = hoverSizes[btn]
		}
	)

	hoverTweens[btn]:Play()
end


local function SetupButtons()
	buttons = {}
	
	for _, child in ipairs(MenuController.SubmenuFolder:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("ImageButton") then
			table.insert(buttons, child)
		end
	end
	
	for _, btn in ipairs(buttons) do
		setAnchorPreservePosition(btn, Vector2.new(0.5, 0.5))
		resetToStart(btn)
	
		if not isTouch then
			btn.MouseEnter:Connect(function()
				onButtonHover(btn)
			end)

			btn.MouseLeave:Connect(function()
				onButtonLeave(btn)
			end)
		end
		
		btn.Size = UDim2.fromScale(btn.Size.X.Scale, btn.Size.Y.Scale)
	end


	total = #buttons
end

function MenuController.toggle()
	--if cd then return end
	--cd = true
	if MenuController.OnToggle then MenuController.OnToggle() end
	
	toggleSubmenu()
	--cd = false
end

function MenuController.ConnectToggle(func)
	if not func then return end
	
	MenuController.OnToggle = func
end

function MenuController.RemoveToggle()
	MenuController.OnToggle = nil
end

local function onHoverEnter()
	if not MenuController.isOpen then
		MenuController.toggle()
	end
end

local function onHoverLeave()
	if MenuController.isOpen then
		MenuController.toggle()
	end
end

function MenuController.Pause()
	if MenuController.Paused then return end
	MenuController.Paused = true
end

function MenuController.Resume()
	if not MenuController.Paused then return end
	MenuController.Paused = false
end

function MenuController.Close()
	if MenuController.isOpen then
		toggleSubmenu()
	end
end

function MenuController.Init(uiController)
	if not uiController then return end
	
	UIController = uiController
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gameUI = playerGui:WaitForChild("GameUI")
	local mainUi = gameUI:WaitForChild("Main").Frame

	local MenuFolder = mainUi:WaitForChild("Menu")
	local openButton = MenuFolder:waitForChild("MenuButton")
	
	local submenuFolder = MenuFolder:WaitForChild("Submenu") 
	local statsFolder = mainUi:WaitForChild("Stats"):WaitForChild("Tweenable")
	
	MenuController.isOpen = false
	MenuController.Paused = false
	MenuController.OnToggle = nil

	MenuController.mainUI = mainUi
	MenuController.MenuFolder = MenuFolder
	MenuController.OpenButton = openButton
	MenuController.SubmenuFolder = submenuFolder
	MenuController.StatsFolder = statsFolder
	
	local hoverArea = Instance.new("Frame")
	hoverArea.Name = "HoverArea"
	hoverArea.BackgroundTransparency = 1
	hoverArea.BorderSizePixel = 0
	hoverArea.Active = true
	hoverArea.ZIndex = isTouch and -1 or 100
	hoverArea.AnchorPoint = Vector2.new(0.5, 0.5)
	hoverArea.Parent = MenuController.MenuFolder
	
	MenuController.HoverArea = hoverArea
	
	task.wait()
	SetupButtons()
	updateHoverArea()
	
	updateRadius()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		updateRadius()
		updateHoverArea()
		if MenuController.isOpen then
			toggleSubmenu()
			toggleSubmenu()
		end
	end)
	
	if hoverEnterConn then hoverEnterConn:Disconnect() end
	if hoverLeaveConn then hoverLeaveConn:Disconnect() end
	
	if isTouch then
		-- phone
		MenuController.OpenButton.Activated:Connect(function()
			if MenuController.Paused then return end
			
			MenuController.toggle()
		end)
	else
		-- pc
		hoverEnterConn = MenuController.HoverArea.MouseEnter:Connect(function()
			if MenuController.Paused then return end
			
			onHoverEnter()
		end)
		hoverLeaveConn = MenuController.HoverArea.MouseLeave:Connect(function()
			if MenuController.Paused then return end
			
			onHoverLeave()
		end)
	end
	
	print('[MenuController] MenuController initialised]')
end

return MenuController
