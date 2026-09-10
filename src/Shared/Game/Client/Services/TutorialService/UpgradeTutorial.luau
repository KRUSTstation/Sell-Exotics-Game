local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local UpgradeTutUI = ReplicatedStorage.Assets.UI.Tutorial.UpgradeTutorial

local UIController = ReplicatedStorage.Game.Client.Controllers.UIController
local MenuController = require(UIController.MenuController)
local ShopMenu = require(UIController.MenuController.ShopMenu)

local shopButton = MenuController.SubmenuFolder:WaitForChild("ShopButton")

local UpgradeTutorial = {}
local UIStates = {}

UpgradeTutorial.player = Players.LocalPlayer
UpgradeTutorial.camera = workspace.CurrentCamera
UpgradeTutorial.playerGui = UpgradeTutorial.player:WaitForChild("PlayerGui")
UpgradeTutorial.tutorialUI = UpgradeTutorial.playerGui.GameUI:WaitForChild("Tutorials")
UpgradeTutorial.ShopFrame = UpgradeTutorial.playerGui.GameUI:WaitForChild("Shop").Frame

UpgradeTutorial._runId = 0

for _, frame in pairs(UpgradeTutUI:GetChildren()) do
	if frame:IsA("Frame") then
		UIStates[frame.Name] = {
			Position = frame.Position
		}
	end
end

function UpgradeTutorial.StartTutorial()
	local char = UpgradeTutorial.player.Character or UpgradeTutorial.player.CharacterAdded:Wait()

	if not UpgradeTutorial._charConn then
		UpgradeTutorial._charConn = UpgradeTutorial.player.CharacterAdded:Connect(function()
			UpgradeTutorial.StartTutorial()
		end)
	end

	UpgradeTutorial._runId += 1
	local runId = UpgradeTutorial._runId
	
	task.wait(1)

	UpgradeTutorial.player = Players.LocalPlayer
	UpgradeTutorial.camera = workspace.CurrentCamera
	UpgradeTutorial.playerGui = UpgradeTutorial.player:WaitForChild("PlayerGui")
	UpgradeTutorial.tutorialUI = UpgradeTutorial.playerGui.GameUI:WaitForChild("Tutorials")
	UpgradeTutorial.ShopFrame = UpgradeTutorial.playerGui.GameUI:WaitForChild("Shop").Frame

	ShopMenu.RemoveTabBarToggle(UpgradeTutorial.ShopFrame.TabsBars.Upgrades)
	if UpgradeTutorial.MenuButton then
		UpgradeTutorial.MenuButton:Destroy()
	end

	if UpgradeTutorial.BlackUI then
		UpgradeTutorial.BlackUI:Destroy()
	end

	ShopMenu.RemoveToggle()

	for _, mod in pairs(UIController.MenuController:GetChildren()) do
		if not mod:IsA("ModuleScript") or mod == UIController.MenuController.ShopMenu then continue end
		local module = require(mod)
		if module and module.Pause then
			module.Resume()
		end
	end
	
	MenuController.RemoveToggle()
	MenuController.Resume()
	MenuController.Close()

	UpgradeTutorial.BlackUI = UpgradeTutUI:WaitForChild("Black"):Clone()
	UpgradeTutorial.MenuButton = UpgradeTutUI:WaitForChild("MenuButton"):Clone()

	UpgradeTutorial.BlackUI.Visible = false
	UpgradeTutorial.MenuButton.Visible = false

	UpgradeTutorial.BlackUI.Parent = UpgradeTutorial.tutorialUI
	UpgradeTutorial.MenuButton.Parent = UpgradeTutorial.tutorialUI

	local size = MenuController.OpenButton.Size

	UpgradeTutorial.MenuButton.Size = UDim2.new(
		size.X.Scale * 5, size.X.Offset * 5,
		size.Y.Scale * 5, size.Y.Offset * 5
	)

	UpgradeTutorial.MenuButton.Position = MenuController.OpenButton.Position

	local t = TweenService:Create(UpgradeTutorial.MenuButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = MenuController.OpenButton.Size, Position = MenuController.OpenButton.Position})

	UpgradeTutorial.BlackUI.Visible = true
	UpgradeTutorial.MenuButton.Visible = true
	t:Play()

	local resume = false
	MenuController.ConnectToggle(function()
		MenuController.Pause()
		resume = true
	end)

	while not resume and runId == UpgradeTutorial._runId do task.wait() end
	if runId ~= UpgradeTutorial._runId then return end
	resume = false

	if t.PlaybackState == Enum.PlaybackState.Playing then
		t:Cancel()
	end

	for _, mod in pairs(UIController.MenuController:GetChildren()) do
		if not mod:IsA("ModuleScript") or mod == UIController.MenuController.ShopMenu then continue end
		local module = require(mod)
		if module and module.Pause then
			module.Pause()
		end
	end

	task.wait(0.7)
	if runId ~= UpgradeTutorial._runId then return end

	local size = shopButton.Size

	UpgradeTutorial.MenuButton.Size = UDim2.new(
		size.X.Scale * 5, size.X.Offset * 5,
		size.Y.Scale * 5, size.Y.Offset * 5
	)

	UpgradeTutorial.MenuButton.Position = shopButton.Position
	local t = TweenService:Create(UpgradeTutorial.MenuButton, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = shopButton.Size, Position = shopButton.Position})

	t:Play()

	ShopMenu.ConnectToggle(function()
		ShopMenu.Pause()
		resume = true
	end)

	while not resume and runId == UpgradeTutorial._runId do task.wait() end
	if runId ~= UpgradeTutorial._runId then return end
	resume = false

	if ShopMenu.OpenGrid ~= UpgradeTutorial.ShopFrame.Tabs.Upgrades then
		local size = UpgradeTutorial.ShopFrame.TabsBars.Upgrades.SmallButton.Size

		local target = UpgradeTutorial.ShopFrame.TabsBars.Upgrades.SmallButton
		local parent = UpgradeTutorial.MenuButton.Parent

		ShopMenu.ConnectTabBarHover(target.Parent, function()
			resume = true
		end)

		task.wait(0.5)
		if runId ~= UpgradeTutorial._runId then return end

		UpgradeTutorial.MenuButton.Size = UDim2.new(
			size.X.Scale * 5, size.X.Offset * 5,
			size.Y.Scale * 5, size.Y.Offset * 5
		)

		local pos = UDim2.fromOffset(
			target.AbsolutePosition.X - parent.AbsolutePosition.X + (target.AbsoluteSize.X / 2),
			target.AbsolutePosition.Y - parent.AbsolutePosition.Y + (target.AbsoluteSize.Y / 2)
		)

		UpgradeTutorial.MenuButton.Position = pos

		local t = TweenService:Create(
			UpgradeTutorial.MenuButton,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.fromOffset(target.AbsoluteSize.X, target.AbsoluteSize.Y),
				Position = pos
			}
		)

		t:Play()

		while not resume and runId == UpgradeTutorial._runId do task.wait() end
		if runId ~= UpgradeTutorial._runId then return end
		resume = false

		ShopMenu.RemoveTabBarHover(target.Parent)

		ShopMenu.ConnectTabBarToggle(target.Parent, function()
			resume = true
		end)

		task.wait(0.5)
		if runId ~= UpgradeTutorial._runId then return end

		local size = UpgradeTutorial.ShopFrame.TabsBars.Upgrades.Button.Size

		UpgradeTutorial.MenuButton.Size = UDim2.new(
			size.X.Scale * 5, size.X.Offset * 5,
			size.Y.Scale * 5, size.Y.Offset * 5
		)

		local target = UpgradeTutorial.ShopFrame.TabsBars.Upgrades.Button
		local parent = UpgradeTutorial.MenuButton.Parent

		local pos = UDim2.fromOffset(
			target.AbsolutePosition.X - parent.AbsolutePosition.X + (target.AbsoluteSize.X / 2),
			target.AbsolutePosition.Y - parent.AbsolutePosition.Y + (target.AbsoluteSize.Y / 2)
		)

		UpgradeTutorial.MenuButton.Position = pos

		local t = TweenService:Create(
			UpgradeTutorial.MenuButton,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = UDim2.fromOffset(target.AbsoluteSize.X, target.AbsoluteSize.Y),
				Position = pos
			}
		)

		t:Play()

		while not resume and runId == UpgradeTutorial._runId do task.wait() end
		if runId ~= UpgradeTutorial._runId then return end
		resume = false

		ShopMenu.RemoveTabBarToggle(target.Parent)
	end

	UpgradeTutorial.MenuButton:Destroy()
	UpgradeTutorial.BlackUI:Destroy()

	ShopMenu.RemoveToggle()

	for _, mod in pairs(UIController.MenuController:GetChildren()) do
		if not mod:IsA("ModuleScript") then continue end
		local module = require(mod)
		if module and module.Pause then
			module.Resume()
		end
	end

	MenuController.RemoveToggle()
	MenuController.Resume()

	return 'completed'
end

return UpgradeTutorial
