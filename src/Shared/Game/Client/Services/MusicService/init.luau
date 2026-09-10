local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local MusicAssignments = require(script:WaitForChild("MusicAssignments"))
local musicFolder = SoundService:WaitForChild("BackgroundMusic")

local MusicService = {}

local tweenTime = 1

MusicService.ActiveSong = nil
MusicService.Paused = false

local changingSong = false

local function GetSoundByName(name)
	return musicFolder:FindFirstChild(name)
end

function MusicService.PlaySong(song)
	if not song or not song:IsA("Sound") then
		warn("[MusicService] PlaySong expected a Sound")
		return
	end
	
	while changingSong do
		task.wait(0.1)
	end

	if MusicService.ActiveSong == song then
		return
	end
	
	changingSong = true
	if MusicService.ActiveSong then
		local oldSong = MusicService.ActiveSong
		local tween = TweenService:Create(oldSong, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Volume = 0})
		tween:Play()
		task.wait(tweenTime/2)
		task.spawn(function()
			tween.Completed:Wait()
			oldSong:Stop()
		end)
	end
	
	MusicService.ActiveSong = song
	local tween = TweenService:Create(song, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Volume = 1})
	song.Volume = 0
	song:Play()
	tween:Play()
	changingSong = false
end

function MusicService.PlayZoneSong(stage)
	local stageSong = MusicAssignments[stage]
	if not stageSong then
		warn("[MusicService] No song assigned for stage:", stage)
		return
	end

	local sound = GetSoundByName(stageSong.Music)
	if not sound then
		warn("[MusicService] Sound not found:", stageSong.Music)
		return
	end

	MusicService.PlaySong(sound)
end

function MusicService.Pause()
	while changingSong do
		task.wait(0.1)
	end
	
	if not MusicService.ActiveSong or MusicService.Paused then
		return
	end

	changingSong = true
	
	task.spawn(function()
		local song = MusicService.ActiveSong
		local tween = TweenService:Create(song, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Volume = 0})
		tween:Play()
		tween.Completed:Wait()
		song:Stop()

		MusicService.Paused = true
		changingSong = false
	end)
	return
end

function MusicService.Resume()
	while changingSong do
		task.wait(0.1)
	end

	if not MusicService.ActiveSong or not MusicService.Paused then
		return
	end
	
	changingSong = true
	
	task.spawn(function()
		local song = MusicService.ActiveSong
		song:Play()
		local tween = TweenService:Create(song, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {Volume = 1})
		tween:Play()
		tween.Completed:Wait()

		MusicService.Paused = false
		changingSong = false
	end)
	return
end

function MusicService.Start()
	task.spawn(function()
		local currentZone = nil

		while true do
			while MusicService.Paused do
				task.wait(0.1)
			end
			
			local char = player.Character or player.CharacterAdded:Wait()
			local hrp = char:FindFirstChild("HumanoidRootPart")

			local foundZone = nil

			if hrp then
				for zoneName, _ in pairs(MusicAssignments) do
					if zoneName == "Global" then
						continue
					end

					local zoneModel = workspace.MusicInfo.BackgroundMusic.Zones:FindFirstChild(zoneName)
					if not zoneModel or not zoneModel:IsA("Model") then
						continue
					end

					local cf, size = zoneModel:GetBoundingBox()
					local relativePos = cf:PointToObjectSpace(hrp.Position)
					local halfSize = size / 2

					if math.abs(relativePos.X) <= halfSize.X
						and math.abs(relativePos.Z) <= halfSize.Z then

						foundZone = zoneName
						break
					end
				end
			end
			
			if foundZone then
				if currentZone ~= foundZone then
					currentZone = foundZone
					MusicService.PlayZoneSong(foundZone)
				end
			else
				if currentZone ~= "Global" then
					currentZone = "Global"
					MusicService.PlayZoneSong("Global")
				end
			end

			task.wait(0.3)
		end
	end)

	print("[MusicService] Started")
end

function MusicService.Init()
	for _, sound in ipairs(musicFolder:GetChildren()) do
		if sound:IsA("Sound") then
			sound.Looped = true
			sound:Stop()
		end
	end
	
	print("[MusicService] Initialized")
end

return MusicService
