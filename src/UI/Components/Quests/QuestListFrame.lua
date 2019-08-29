local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"

local QuestListFrame = Roact.PureComponent:extend("QuestListFrame")
local QuestInformationFrame = import "../QuestInformationFrame"
local QuestRewardFrame = import "../QuestRewardFrame"
local QuestData = import "Shared/Data/QuestData"

local function countRewards(questID)
	local data = QuestData.lookupByID(questID)
	local rewards = 0
	for _,_ in pairs(data.reward) do
		rewards = rewards + 1
	end
	return rewards
end

function QuestListFrame:init(suppliedProps)
	self.size = suppliedProps.size
	self.position = suppliedProps.position
end

function QuestListFrame:onUpdate()

end

function QuestListFrame:render(props)
	local padding = 6
	local questFrames = {}
	local questsNumber = 0
	for _,_ in pairs(self.props.quests) do
		questsNumber = questsNumber + 1
	end
	local i = 0
	for questID, quest in pairs(self.props.quests) do
		i = i + 1
		table.insert(questFrames, Roact.createElement(QuestInformationFrame, {
			size = UDim2.new(1,0,0, 50 -padding),
			quest = quest,
			questID = questID,
			layoutOrder = i,
		}))
		i = i + 1
		local rewardNum = countRewards(questID)
		table.insert(questFrames, Roact.createElement(QuestRewardFrame, {
			size = UDim2.new(1,-8,0, 30*rewardNum),
			quest = quest,
			questID = questID,
			layoutOrder = i
		}))
	end
	local frame = Roact.createElement("Frame", {
		Size = self.size,
		Position = self.position,
		BackgroundTransparency = 1,
	}, {
		List = Roact.createElement("UIListLayout", {
			VerticalAlignment = "Top",
			HorizontalAlignment = "Center",
			FillDirection = "Vertical",
			Padding = UDim.new(0,padding),
			SortOrder = "LayoutOrder",
		}),
		unpack(questFrames)
	})
	return frame
end

return QuestListFrame
