local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"
local YesNoDialogue = Roact.PureComponent:extend("YesNoDialogue")
local Frame = import "UI/Components/Frame"
local StyleConstants = import "Shared/Data/StyleConstants"

function YesNoDialogue:init()
	self:setState({
		visible = false,
		text = "JOIN SECURITY?",
		yesCallback = function()
			self:setState({visible = false})
		end,
	})
	Messages:hook("OpenYesNoDialogue", function(props)
		local state = {visible = true}
		for i, v in pairs(props) do
			state[i] = v
		end
		self:setState(state)
	end)
end

function YesNoDialogue:render()
	return Frame({
		size = UDim2.new(0.25,0,0.35,0),
		position = UDim2.new(.5,0,.5,0),
		visible = self.state.visible,
		anchorPoint = Vector2.new(.5,.5),
		aspectRatio = 1.2,
		closeCallback = function()
			self:setState({visible = false})
		end,
	}, {
		TextLabel = Roact.createElement("TextLabel", {
			Size = UDim2.new(.8,0,.4,0),
			Position = UDim2.new(.5,0,.2,0),
			BackgroundTransparency = 1,
			TextScaled = true,
			Text = self.state.text,
			Font = "SourceSans",
			TextStrokeTransparency = 1,
			TextColor3 = Color3.new(0,0,0),
			ZIndex = 2,
			AnchorPoint = Vector2.new(.5,0),
		}),
		YesButton = Roact.createElement("TextButton", {
			Size = UDim2.new(.25,0,.15,0),
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundColor3 = StyleConstants.YES_COLOR,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundTransparency = 1,
			Font = "SourceSans",
			TextColor3 = Color3.new(0,0,0),
			Text = "YES",
			Position = UDim2.new(.3,0,.85,0),
			[Roact.Event.Activated] = function()
				self.state.yesCallback()
				self:setState({visible = false})
			end,
			ZIndex = 6,
		}),
		YesButtonImage = Roact.createElement("ImageButton", {
			Size = UDim2.new(.25,0,.15,0),
			AnchorPoint = Vector2.new(.5,.5),
			Image = "rbxassetid://3677918992",
			BackgroundTransparency = 1,
			ScaleType = "Slice",
			SliceCenter = Rect.new(512,512,512,512),
			ImageColor3 = StyleConstants.YES_COLOR,
			Position = UDim2.new(.3,0,.85,0),
			[Roact.Event.Activated] = function()
				self:setState({visible = false})
			end,
			ZIndex = 5,
		}),
		NoButton = Roact.createElement("TextButton", {
			Size = UDim2.new(.25,0,.15,0),
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundColor3 = StyleConstants.TAB_COLOR,
			BorderSizePixel = 0,
			TextScaled = true,
			BackgroundTransparency = 1,
			Font = "SourceSans",
			TextColor3 = Color3.new(0,0,0),
			Text = "NO",
			Position = UDim2.new(.7,0,.85,0),
			[Roact.Event.Activated] = function()
				self:setState({visible = false})
			end,
			ZIndex = 6,
		}),
		NoButtonImage = Roact.createElement("ImageButton", {
			Size = UDim2.new(.25,0,.15,0),
			AnchorPoint = Vector2.new(.5,.5),
			Image = "rbxassetid://3677918992",
			ScaleType = "Slice",
			BackgroundTransparency = 1,
			SliceCenter = Rect.new(512,512,512,512),
			ImageColor3 = StyleConstants.TAB_COLOR,
			Position = UDim2.new(.7,0,.85,0),
			[Roact.Event.Activated] = function()
				self:setState({visible = false})
			end,
			ZIndex = 5,
		}),
	})
end

return YesNoDialogue
