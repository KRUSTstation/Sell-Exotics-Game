local QuestController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestUpdate = ReplicatedStorage.Remotes.QuestEvents:WaitForChild("QuestUpdate")

QuestController.PlayerQuests = {}

QuestUpdate.OnClientEvent:Connect(function(action, questType, questId, value)	
	if action == "Started" then
		QuestController.PlayerQuests[questType] = {}
		
		QuestController.PlayerQuests[questType][questId] = {
			Progress = value
		}

	elseif action == "Progress" then
		if QuestController.PlayerQuests[questType] and QuestController.PlayerQuests[questType][questId] then
			QuestController.PlayerQuests[questType][questId].Progress = value
		end
	end
	
	print("Quest update:",questType,questId,value)
end)

return QuestController