local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SFX = ReplicatedStorage.Assets.SFX

local TweenService = game:GetService("TweenService")

local TweenHelper = {}

local UIInfo = {}

function TweenHelper.MainUITween(frame, enter)
	local info = UIInfo[frame]
	if not info then warn("UIInfo not found for frame: " .. frame.Name) return end
	
	local tween
	
	if enter then
		frame.Position = UDim2.new(info.Position.X.Scale, 0, 1, 0)
		tween = TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(info.Position.X.Scale, 0, info.Position.Y.Scale, 0)})
	else
		frame.Position = UDim2.new(info.Position.X.Scale, 0, info.Position.Y.Scale, 0)
		tween = TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(info.Position.X.Scale, 0, 1, 0)})
	end
	
	SFX.UI:WaitForChild("Swipe1"):Play()
	tween:Play()
	return tween
end

function TweenHelper.Init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	for _, instance in pairs(playerGui:GetDescendants()) do
		if instance:IsA("Frame") or instance:IsA("ScrollingFrame") then
			UIInfo[instance] = {Position = instance.Position, Size = instance.Size}
		end
	end
	
	print("[TweenHelper] TweenHelper initialised")
end

return TweenHelper
