local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ActivateToolEvent = ReplicatedStorage.Remotes.ToolEvents:WaitForChild("ActivateTool")
local Players = game:GetService("Players")

local ToolsController = {}

local function connectTool(tool)
	if tool:IsA("Tool") then
		tool.Activated:Connect(function()
			ActivateToolEvent:FireServer(tool)
		end)
	end
end

local function ToolsInit()
	local player = Players.LocalPlayer
	
	for _, tool in ipairs(player.Backpack:GetChildren()) do
		connectTool(tool)
	end

	player.Backpack.ChildAdded:Connect(connectTool)

	player.CharacterAdded:Connect(function()
		task.wait(5)
		for _, tool in ipairs(player.Backpack:GetChildren()) do
			connectTool(tool)
		end
	end)
end

function ToolsController.Init()
	ToolsInit()
	print("[ToolsController] ToolsController Initialized")
end

return ToolsController
