local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local TextBar = import "UI/Components/Quests/TextBar"
local QuestData = import "Shared/Data/QuestData"
local StyleConstants = import "Shared/Data/StyleConstants"

local QuestRewardFrame = Roact.PureComponent:extend("QuestRewardFrame")

function QuestRewardFrame:init(suppliedProps)
	self.size = suppliedProps.size
	self.quest = suppliedProps.quest
	self.questID = self.props.questID
end

function QuestRewardFrame:render(props)
	local quest = self.props.quest
	local questInfo = QuestData.lookupByID(self.questID)

	local rewardFrames=  {}

	local rewards = questInfo.reward
	for rewardName, amount in pairs(rewards) do
		table.insert(rewardFrames, Roact.createElement("Frame", {
			Size = UDim2.new(1,0,0,24),
			BackgroundTransparency =1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0,2),
				PaddingBottom = UDim.new(0,2),
				PaddingLeft = UDim.new(0,4),
				PaddingRight = UDim.new(0,4),
			}),
			Icon = Roact.createElement("ImageLabel", {
				SizeConstraint = "RelativeYY",
				Size = UDim2.new(1,0,1,0),
				Image = "rbxassetid://3711769071",
				BackgroundTransparency =1 ,
				ZIndex = 8,
				Visible = false,-- delete this if you do real icons
			}),
			TextLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(.75,0,1,0),
				BackgroundTransparency = 1,
				Font = "Gotham",
				TextScaled = true,
				TextXAlignment = "Right",
				Text = rewardName.." x "..amount,
				ZIndex = 8,
			})
		}))
	end

	return  Roact.createElement("ImageLabel", { -- actual outline frame
		Size = self.props.size,
		Position = UDim2.new(0,4,0,0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Image = "rbxassetid://3677918992",--rbxassetid://3677918992",
		ScaleType = "Slice",
		SliceCenter = Rect.new(512,512,512,512),
		ImageColor3 = Color3.new(0,0,0),
		ZIndex = 4,
		LayoutOrder = self.props.layoutOrder,
	}, {
		RealFrame = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0,2,0,2),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Image = "rbxassetid://3677918992",--rbxassetid://3677918992",
			ScaleType = "Slice",
			SliceCenter = Rect.new(512,512,512,512),
			ImageColor3 = StyleConstants.TAB_COLOR,
			ZIndex = 5,
		}, {
			List = Roact.createElement("UIListLayout", {
				VerticalAlignment = "Top",
				HorizontalAlignment = "Center",
				FillDirection = "Vertical",
				Padding = UDim.new(0,4)
			}),
			unpack(rewardFrames)
		}),
	})
end

return QuestRewardFrame
