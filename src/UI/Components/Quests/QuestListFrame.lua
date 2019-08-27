local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"

local QuestListFrame = Roact.PureComponent:extend("QuestListFrame")
local QuestInformationFrame = import "../QuestInformationFrame"
local QuestRewardFrame = import "../QuestRewardFrame"

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
	for questID, quest in pairs(self.props.quests) do

		table.insert(questFrames, Roact.createElement(QuestInformationFrame, {
			size = UDim2.new(1,0,0, 50 -padding),
			quest = quest,
			questID = questID
		})) -- (1/questsNumber)
		table.insert(questFrames, Roact.createElement(QuestRewardFrame, {
			size = UDim2.new(1,0,0, 30 -padding),
			quest = quest,
			questID = questID
		}))
		-- after this insert the reward frame seperately, this is just easier to do
		-- for the size do
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
			Padding = UDim.new(0,padding)
		}),
		unpack(questFrames)
	})
	return frame
end

return QuestListFrame
