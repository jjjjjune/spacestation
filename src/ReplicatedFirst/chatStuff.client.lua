
local Chat = game:GetService("Chat")

local function setUpChatWindow()
	return {BubbleChatEnabled = true,ClassicChatEnabled = true}
end

while not pcall(function()
		Chat:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow, setUpChatWindow)
	end) do
	wait()
end

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
