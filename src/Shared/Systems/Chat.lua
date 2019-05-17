local import = require(game.ReplicatedStorage.Shared.Import)

local CHAT_DECAY_TIME = 15

local Chat = {}

local MessageUiCanvas = import "Assets/ChatAssets/ChatCanvas"
local ChatConstants =  import "Shared/Data/ChatConstants"
local Messages = import "Shared/Utils/Messages"

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local messagePartCache = {}

local function clearTails(part)
	for i, v in pairs(messagePartCache[part]:GetChildren()) do
		if v.Parent == nil then
			messagePartCache[part][i] = nil
		else
			if v:IsA("Frame") then
				v.Frame.Visible = false
			end
		end
	end
end

local function countFrames(part)
	local num = 0
	for _, v in pairs(messagePartCache[part]:GetChildren()) do
		if v:IsA("Frame") and  v.Visible == true then
			num = num + 1
		end
	end
	return num
end

local function getPercentageCapital(message)
	-- returns how much of a message is in capital letters
	local totalLetters = string.len(message)
	local totalCapitals = 0
	for index = 1, totalLetters do
		local char = string.sub(message, index)
		if char == char:upper() and char:upper() ~= char:lower() then
			-- the second statement is for non-latin alphabets, we'll have to do yelling a different way for them
			totalCapitals = totalCapitals + 1
		end
	end
	return totalCapitals/totalLetters
end

local function getChatData(message)
	local messageData = {
		type = "talking",
		color = Color3.fromRGB(4,17,22),
		scale = 1,
		font = "SourceSans"
	}
	if getPercentageCapital(message) > ChatConstants.YELL_CAPITAL_THERSHOLD then
		messageData.type = "yelling"
		messageData.color = ChatConstants.YELL_COLOR
		messageData.scale = ChatConstants.YELL_SCALE
		messageData.font = ChatConstants.YELL_FONT
	end
	if string.sub(message,1,1) == "(" then
		messageData.type = "whispering"
		messageData.color = ChatConstants.WHISPER_COLOR
		messageData.scale = ChatConstants.WHISPER_SCALE
		messageData.font = ChatConstants.WHISPER_FONT
	end
	return messageData
end

local function onChatInstanceAdded(messageUiInstance, part)
	spawn(function()
		wait(CHAT_DECAY_TIME)
		messageUiInstance:Destroy()
		if countFrames(part) == 0 then
			messagePartCache[part]:Destroy()
			messagePartCache[part] = nil
		end
	end)
end

local function onPlayerAdded(player)
	player.Chatted:connect(function(msg)
		for _, playerToSend in pairs(game.Players:GetPlayers()) do
			spawn(function()
				local filteredTextResult = TextService:FilterStringAsync(msg, player.UserId)
				Messages:sendClient(playerToSend, "DisplayChatMessage", player, filteredTextResult:GetChatForUserAsync(playerToSend.UserId))
			end)
		end
	end)
end

local function onChatAddedEffect(instance, data)
	if data.type == "yelling" then
		instance:TweenSize(instance.Size + UDim2.new(.15,0,.15,0), "Out", "Quad", .15)
		spawn(function()
			wait(.15)
			instance:TweenSize(instance.Size - UDim2.new(.15,0,.15,0), "Out", "Quad", .15)
		end)
	elseif data.type == "talking" then
		instance:TweenSize(instance.Size + UDim2.new(.025,0,.025,0), "Out", "Quad", .1)
		spawn(function()
			wait(.1)
			instance:TweenSize(instance.Size - UDim2.new(.025,0,.025,0), "Out", "Quad", .1)
		end)
	end
end

function Chat:displayChatMessage(part, message)
	if not messagePartCache[part] then
		messagePartCache[part] = MessageUiCanvas:Clone()
		messagePartCache[part].Parent = part
	end
	local messageUiInstance = MessageUiCanvas.TemplateFrame:Clone()
	local holder = messagePartCache[part]
	local stringLength = string.len(message)
	local ySize = math.min(1.5, math.ceil(stringLength/80)*.125)
	local xSize = math.min(2, math.ceil(stringLength/40)*.2)
	local chatData = getChatData(message)
	clearTails(part)
	messageUiInstance.Parent = holder
	messageUiInstance.Size = UDim2.new(math.min(1, xSize*chatData.scale),0,ySize*chatData.scale,0)
	messageUiInstance.Label.Text = message
	messageUiInstance.Name = "UsedFrame"
	messageUiInstance.Visible = true
	messageUiInstance.Label.TextColor3 = chatData.color
	messageUiInstance.Label.Font = chatData.font
	messageUiInstance.UIAspectRatioConstraint.AspectRatio = xSize/ySize
	onChatAddedEffect(messageUiInstance, chatData)
	onChatInstanceAdded(messageUiInstance,part)
end

function Chat:start()
	if RunService:IsClient() then
		Messages:hook("DisplayChatMessage", function(sender, filteredMessage)
			local character = sender.Character
			if character then
				self:displayChatMessage(character.PrimaryPart, filteredMessage)
			end
		end)
	else
		game.Players.PlayerAdded:connect(function(player)
			onPlayerAdded(player)
		end)
	end
end

return Chat
