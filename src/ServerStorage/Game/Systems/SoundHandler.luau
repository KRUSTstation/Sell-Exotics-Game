local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes.SoundEvents

local SoundHandler = {}
local Sounds = {}

function SoundHandler.PlayClientSound(player: Player, sound: Sound, maxLength: number)
	local id = SoundHandler.PlayClientSoundFunction:InvokeClient(player, sound, maxLength)
	if not Sounds[player.UserId] then Sounds[player.UserId] = {} end
	
	table.insert(Sounds[player.UserId], id)
	return id
end

function SoundHandler.ClientSoundEnded(player, idtoCheck)
	if Sounds[player.UserId] then
		for i, id in ipairs(Sounds[player.UserId]) do
			if id == idtoCheck then
				table.remove(Sounds[player.UserId], i)
			end
		end
	end
end

function SoundHandler.StopClientSound(player, id)
	SoundHandler.StopClientSoundEvent:FireClient(player, id)
end

local function EventsInit()
	SoundHandler.PlayClientSoundFunction = Instance.new('RemoteFunction')
	SoundHandler.PlayClientSoundFunction.Name = 'PlayClientSound'
	SoundHandler.PlayClientSoundFunction.Parent = Remotes
	
	SoundHandler.SoundEndedEvent = Instance.new('RemoteEvent')
	SoundHandler.SoundEndedEvent.Name = 'SoundEnded'
	SoundHandler.SoundEndedEvent.Parent = Remotes
	SoundHandler.SoundEndedEvent.OnServerEvent:Connect(function(player, id)
		SoundHandler.ClientSoundEnded(player, id)
	end)
	
	SoundHandler.StopClientSoundEvent = Instance.new('RemoteEvent')
	SoundHandler.StopClientSoundEvent.Name = 'StopClientSound'
	SoundHandler.StopClientSoundEvent.Parent = Remotes
end

function SoundHandler.Init()
	EventsInit()
	
	print("[SoundHandler] Initialised")
end

return SoundHandler
