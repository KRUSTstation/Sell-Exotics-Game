local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.UIEvents.NotifEvents

local NotifHandler = {}

function NotifHandler.SendCustomNotif(player: Player, text: string, color: Color3, timeForAlive: number, sound: Sound)
	NotifHandler.SendCustomNotifEvent:FireClient(player, text, color, timeForAlive, sound)
end

function NotifHandler.SendInsufficientStrenghtNotif(player: Player)
	NotifHandler.InsufficientStrenghtNotifEvent:FireClient(player)
end

local function EventsInit()
	NotifHandler.SendCustomNotifEvent = Instance.new('RemoteEvent')
	NotifHandler.SendCustomNotifEvent.Name = 'SendCustomNotif'
	NotifHandler.SendCustomNotifEvent.Parent = Remotes
	
	NotifHandler.InsufficientStrenghtNotifEvent = Instance.new('RemoteEvent')
	NotifHandler.InsufficientStrenghtNotifEvent.Name = 'InsufficientStrenghtNotif'
	NotifHandler.InsufficientStrenghtNotifEvent.Parent = Remotes

end

function NotifHandler.Init()
	EventsInit()
	
	print("[NotifHandler] Initialised")
end

return NotifHandler
