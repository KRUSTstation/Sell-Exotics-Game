local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local DataHandler = require(ServerStorage.Game.Systems:WaitForChild("DataHandler"))

local RemotesFolder = ReplicatedStorage.Remotes.QuestEvents

local QuestController = {}

QuestController.Remotes = {}

QuestController.Quests = {}

function QuestController.StartQuest(player, typeOfQuest, questId)
	local questType = QuestController.Quests[typeOfQuest]
	if not questType then return end

	local quest = questType[questId]
	if not quest then return end
	
	local playerData = DataHandler.GetData(player)
	if not playerData then return end
	
	local playerQuests = playerData.Quests

	playerQuests =
		playerQuests or {}

	playerQuests[typeOfQuest] =
		playerQuests[typeOfQuest] or {}

	playerQuests[typeOfQuest][questId] = 
		playerQuests[typeOfQuest][questId] or 
		{
		Progress = 0,
		Completed = false
		}
	
	DataHandler.SetData(player, playerData)
	QuestController.Remotes.QuestUpdateRemote:FireClient(player,"Started",typeOfQuest,questId,0)
end

function QuestController.AddProgress(player, objectiveType, target, amount)
	local playerData = DataHandler.GetData(player)
	if not playerData then return end
	
	local playerQuests = playerData.Quests
	
	for questType, quests in pairs(playerQuests) do
		for questId, data in pairs(quests) do
			local quest = QuestController.Quests[questType][questId]

			if data.Completed then continue end

			if quest.ObjectiveType == objectiveType then
				if quest.Target == target then
					data.Progress += amount
					
					if data.Progress >= quest.Amount then
						data.Completed = true
					
						if quest.Rewards.Coins then
							DataHandler.SetStat(player,'Coins',
								playerData.Stats.Coins + quest.Rewards.Coins)
						end
						if quest.Rewards.XP then
							DataHandler.SetStat(player,'XP',
								playerData.Stats.XP + quest.Rewards.XP)
						end

						print(player.Name.." completed "..quest.Name)
					end
					
					DataHandler.SetData(player, playerData) -- can make a function inside datahandler to do this do i can auto fire remote to client for ui (or use quest client)

					QuestController.Remotes.QuestUpdateRemote:FireClient(
						player,
						"Progress",
						questType,
						questId,
						data.Progress
					)
				end
			end
		end
	end
end

local function EventsInit()
	QuestController.Remotes.QuestUpdateRemote = Instance.new('RemoteEvent', RemotesFolder)
	QuestController.Remotes.QuestUpdateRemote.Name = 'QuestUpdate'
end

function QuestController.Init()	
	for _, module in ServerStorage.Data.Quests:GetDescendants() do
		if module:IsA("ModuleScript") then

			local questType = module.Name
			local quests = require(module)

			QuestController.Quests[questType] = {}

			for _, quest in pairs(quests) do
				QuestController.Quests[questType][quest.Id] = quest
			end

		end
	end
	
	EventsInit()
	print('[QuestController] Initialised')
end

return QuestController
