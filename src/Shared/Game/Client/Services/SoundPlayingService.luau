local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Remotes = ReplicatedStorage.Remotes.SoundEvents

local PlayClientSoundFunction = Remotes:WaitForChild("PlayClientSound")
local SoundEndedEvent = Remotes:WaitForChild("SoundEnded")
local StopClientSoundEvent = Remotes:WaitForChild("StopClientSound")

local SoundPlayingService = {}
local PlayingSounds = {}

function SoundPlayingService.PlaySound(sound: Sound, maxLength: number)
	if not sound or not sound:IsA("Sound") then 
		warn("Invalid sound") 
		return 
	end

	local newSound = sound:Clone()
	newSound.Parent = sound.Parent

	local id = HttpService:GenerateGUID(false)
	newSound:SetAttribute("SoundId", id)

	newSound:Play()
	PlayingSounds[id] = newSound

	local connection
	connection = newSound.Ended:Connect(function()
		SoundPlayingService.StopSound(id)
		connection:Disconnect()
	end)
	if maxLength then
		task.delay(maxLength, function()
			if PlayingSounds[id] then
				SoundPlayingService.StopSound(id)
				connection:Disconnect()
			end
		end)
	end

	return id
end

function SoundPlayingService.StopSound(id)
	local sound = PlayingSounds[id]
	if sound then
		sound:Stop()
		sound:Destroy()
		PlayingSounds[id] = nil
		SoundEndedEvent:FireServer(id)
	end
end

local function EventsInit()
	PlayClientSoundFunction.OnClientInvoke = function(sound: Sound)
		return SoundPlayingService.PlaySound(sound)
	end
	
	StopClientSoundEvent.OnClientEvent:Connect(function(id)
		SoundPlayingService.StopSound(id)
	end)
end

function SoundPlayingService.Init()
	EventsInit()
	
	print('[SoundPlayingService] Initialised')
end

return SoundPlayingService
