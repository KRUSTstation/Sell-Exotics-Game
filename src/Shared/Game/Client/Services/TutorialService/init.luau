local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes.DataEvents.TutorialEvents
local StartTutorialFunction = Remotes:WaitForChild("StartTutorial")

local TutorialService = {}

function TutorialService.StartTutorial(tutorial)
	local tutScript = script:FindFirstChild(tutorial)
	if not tutScript then warn(tutorial .. " tutorial does not exist"); return end
	
	return require(tutScript).StartTutorial()
end

local function EventsInit()
	StartTutorialFunction.OnClientInvoke = TutorialService.StartTutorial
end

function TutorialService.Init()
	EventsInit()
	
	print("[TutorialService] Initialised")
end

return TutorialService
