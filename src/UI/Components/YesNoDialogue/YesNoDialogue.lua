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
			Size = UDim2.new(.8,0,.5,0),
			Position = UDim2.new(.5,0,.15,0),
			BackgroundTransparency = 1,
			TextScaled = true,
			Text = self.state.text,
			Font = "SciFi",
			TextStrokeTransparency = .5,
			TextColor3 = Color3.new(1,1,1),
			ZIndex = 2,
			AnchorPoint = Vector2.new(.5,0),
		}),
		YesButton = Roact.createElement("TextButton", {
			Size = UDim2.new(.25,0,.15,0),
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundColor3 = StyleConstants.YES_COLOR,
			BorderSizePixel = 0,
			TextScaled = true,
			Font = "SciFi",
			TextColor3 = Color3.new(1,1,1),
			Text = "YES",
			Position = UDim2.new(.3,0,.8,0),
			[Roact.Event.Activated] = function()
				self.state.yesCallback()
				self:setState({visible = false})
			end,
		}),
		NoButton = Roact.createElement("TextButton", {
			Size = UDim2.new(.25,0,.15,0),
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundColor3 = StyleConstants.TAB_COLOR,
			BorderSizePixel = 0,
			TextScaled = true,
			Font = "SciFi",
			TextColor3 = Color3.new(1,1,1),
			Text = "NO",
			Position = UDim2.new(.7,0,.8,0),
			[Roact.Event.Activated] = function()
				self:setState({visible = false})
			end,
		}),
	})
end

return YesNoDialogue
