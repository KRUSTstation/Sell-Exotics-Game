local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ToolFunctions = require(ServerStorage.Data.Shop.Tools:WaitForChild("ToolsFunctions"))

local ToolsHandler = {}

local function ActivateTool(player, tool)
	local tool_name = tool.Name
	local tool_function = ToolFunctions[tool_name]
	if tool_function then
		tool_function(player, tool)
	end
end

local function EventsInit()
	local folder = ReplicatedStorage.Remotes.ToolEvents
	
	local ActivateToolEvent = Instance.new("RemoteEvent")
	ActivateToolEvent.Name = "ActivateTool"
	ActivateToolEvent.Parent = folder
	ActivateToolEvent.OnServerEvent:Connect(ActivateTool)
end

function ToolsHandler.Init()
	EventsInit()
	print("[ToolsHandler] ToolsHandler Initialised")
end

return ToolsHandler
