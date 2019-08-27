local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local TextBar = import "UI/Components/Quests/TextBar"
local QuestData = import "Shared/Data/QuestData"

local function formatString(timeRemaining)
	local hours = math.floor(timeRemaining/3600)
	local minutes = math.floor((timeRemaining - (hours * 3600))/60)
	local seconds = math.floor(timeRemaining - (minutes*60) - (hours * 3600))
	local hoursString = hours..""
	local minutesString = minutes..""
	local secondsString = seconds..""

	if hours < 10 then
		hoursString = "0"..hoursString
		if hours == 0 then
			hoursString = ""
		end
	end
	if minutes < 10 then
		minutesString = "0"..minutesString
		if minutes == 0 then
			minutesString = ""
		end
	end
	if seconds < 10 then
		secondsString = "0"..secondsString
	end
	return hoursString..":"..minutesString..":"..secondsString
end

local QuestInformationFrame = Roact.PureComponent:extend("QuestInformationFrame")

function QuestInformationFrame:init(suppliedProps)
	self.size = suppliedProps.size
	self.quest = suppliedProps.quest
	self.questID = self.props.questID
end

function QuestInformationFrame:render(props)
	local quest = self.props.quest
	local questInfo = QuestData.lookupByID(self.questID)

	local currentAmount = _G.Data and _G.Data[quest.stat] or 0
	local startAmount = quest.startAmount
	local endAmount = quest.endAmount
	local needed = endAmount - startAmount
	local currentlyHave = math.max(0,currentAmount - startAmount)

	local timeString = ""
	local timeRemaining = quest.timeEnd - tick()
	if timeRemaining> 1000000 then
		-- okay this means its not a timed quest
	else
		timeString = formatString(timeRemaining)
	end

	return Roact.createElement("Frame", {
		Size = self.props.size,
		BackgroundTransparency =1,
	}, {
		QuestTitle = Roact.createElement("TextLabel", {
			Text= [[]]..questInfo.title..[[]],
			Size = UDim2.new(.6,0,.4,0),
			Position = UDim2.new(0,4,0,0),
			BackgroundTransparency = 1,
			Font = "GothamSemibold",
			TextScaled = true,
			TextXAlignment = "Left"
		}),
		TimeRemaining = Roact.createElement("TextLabel", {
			Text= timeString,
			Position = UDim2.new(0,0,.1,0),
			Size = UDim2.new(1,0,.3,0),
			BackgroundTransparency = 1,
			Font = "Gotham",
			TextScaled = true,
			TextXAlignment = "Right"
		}),
		QuestBar = Roact.createElement(TextBar, {
			size = UDim2.new(1,-8,.6,0),
			primaryColor = Color3.fromRGB(157,255,183),
			visible = true,
			amount = currentlyHave,
			maxAmount = needed,
			secondaryColor = Color3.fromRGB(186,255,222),
			position = UDim2.new(0,4,.4,0),
			text= currentlyHave.." / "..needed..questInfo.verb,
		}),
	})
end

return QuestInformationFrame
