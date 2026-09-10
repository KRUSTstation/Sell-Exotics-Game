local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SystemMessageRE

local ChatHandler = {}

function ChatHandler.SendGlobalMessage(ctx: string, color: Color3, font: Enum.Font, textSize: number)
	SystemMessageRE:FireAllClients(ctx, color, font, textSize)
end

local function EventsIni()
	SystemMessageRE = Instance.new("RemoteEvent")
	SystemMessageRE.Name = "SystemMessageRemote"
	SystemMessageRE.Parent = ReplicatedStorage.Remotes.UIEvents
end

function ChatHandler.Init()
	EventsIni()
	
	print("[ChatHandler] ChatHandler initialized")
end

return ChatHandler
