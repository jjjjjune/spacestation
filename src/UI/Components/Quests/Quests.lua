local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local UserInputService = game:GetService("UserInputService")
local StyleConstants = import "Shared/Data/StyleConstants"

local Roact = import "Roact"
local Quests = Roact.PureComponent:extend("Quests")
local QuestData = import "Shared/Data/QuestData"
local QuestListFrame = import "../QuestListFrame"

local function filterQuests(questsTab)
	local player = game.Players.LocalPlayer
	local myQuests = {}
	for questID, quest in pairs(questsTab) do
		if quest.team == player.Team.Name:lower() or (not quest.isTeam) then
			myQuests[questID] = quest
		end
	end
	return myQuests
end

function Quests:init()
	self.state = {quests = {}}
	Messages:hook("PlayerDataSet", function(data)
		self:setState({
			quests = filterQuests(data.quests) or {}
		})
	end)
end

function Quests:render()
	local scale =  1.25
	if UserInputService.TouchEnabled then
		scale = 1
	end

	local questsNumber = 0
	local rewardsNumber = 0
	for id, quest in pairs(self.state.quests) do
		questsNumber = questsNumber + 1
		local data = QuestData.lookupByID(id)
		for _, _ in pairs(data.reward) do
			rewardsNumber = rewardsNumber + 1
		end
	end

	local height = 50 * (questsNumber) -- 50 pixels per info frame or so
	height = height + 36 * rewardsNumber -- each reward will have about 30 pixels of size
	height = height + 56 -- height of the title label probably
	local noActiveQuestsMessageShown = false

	if questsNumber == 0 then
		scale = .1
		noActiveQuestsMessageShown = true
	end


	return  Roact.createElement("ImageLabel", { -- actual outline frame
		Size = UDim2.new(0.05,180,0,height),
		Position = UDim2.new(0,0,1,0),
		AnchorPoint = Vector2.new(0,1),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3677918992",--rbxassetid://3677918992",
		ScaleType = "Slice",
		SliceCenter = Rect.new(512,512,512,512),
		ImageColor3 = Color3.new(0,0,0),
		ZIndex = -1,
	}, {
		RealFrame = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Image = "rbxassetid://3677918992",--rbxassetid://3677918992",
			ScaleType = "Slice",
			SliceCenter = Rect.new(512,512,512,512),
			ImageColor3 = StyleConstants.WINDOW_BG,
			ZIndex = 1,
		}),
		TitleFrame = Roact.createElement("TextLabel", {
			TextScaled = true,
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,24),
			Font = "GothamBold",
			Text= "Jobs: ",
			TextColor3 = Color3.new(0,0,0),
			TextXAlignment = "Left",
			Position = UDim2.new(0,6,0,4),
			ZIndex = 2,
		}),
		NoActiveQuestsFrame = Roact.createElement("TextLabel", {
			TextScaled = true,
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,.3,0),
			Font = "Gotham",
			Text= "No active jobs!",
			AnchorPoint = Vector2.new(0,.5),
			TextColor3 = Color3.new(0,0,0),
			TextXAlignment = "Left",
			Position = UDim2.new(0,4,0.7,0),
			Visible = noActiveQuestsMessageShown,
			ZIndex = 2,
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0,2),
			PaddingRight = UDim.new(0,2),
			PaddingTop = UDim.new(0,2),
			PaddingBottom = UDim.new(0,2),
		}),
		QuestListFrame = Roact.createElement(QuestListFrame, {
			quests = self.state.quests,
			size = UDim2.new(1,0,1,-36),
			position = UDim2.new(0,0,0,30)
		})
	})
end

return Quests
