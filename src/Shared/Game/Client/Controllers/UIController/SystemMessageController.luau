local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local SystemMessageRE = ReplicatedStorage.Remotes.UIEvents:WaitForChild("SystemMessageRemote")

local SystemMessageController = {}

local function getFontName(fontEnum)
    if typeof(fontEnum) ~= "EnumItem" or fontEnum.EnumType ~= Enum.Font then
        error("Argument must be an Enum.Font value")
    end
    return fontEnum.Name
end

local function color3ToHex(color)
	return string.format("#%02X%02X%02X",
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		math.floor(color.B * 255)
	)
end

local function sendSystemMessage(message, color, font, textSize)
	color = color or Color3.fromRGB(255, 255, 255)
	font = font or Enum.Font.SourceSansBold
	textSize = textSize or 18

	color = color3ToHex(color)
	font = getFontName(font)

	local richText = string.format(
		"<font color='%s' size='%d' face='%s'>%s</font>",
		color,
		textSize,
		font,
		'[Server] '..message
	)

	TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(richText)
end

function SystemMessageController.Init()
	SystemMessageRE.OnClientEvent:Connect(sendSystemMessage)
	
	print('[SystemMessageController] SystemMessageController initialized')
end

return SystemMessageController


