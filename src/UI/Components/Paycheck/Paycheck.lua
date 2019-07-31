local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"
local Paycheck = Roact.PureComponent:extend("Paycheck")
local Frame = import "UI/Components/Frame"
local StyleConstants = import "Shared/Data/StyleConstants"

local function getPaycheckEntryData(index, value, n)
	return {
		text = index,
		amount = value,
		start = tick(),

	}
end

function Paycheck:init()
	self:setState({
		visible = false,
		paycheckFrames = {}
	})
	Messages:hook("DisplayPaycheck", function(data)
		print("got display paycheck")
		spawn(function()
			self.state.paycheckFrames = {}
			self.state.visible = true
			local total = 0
			local n = 0
			local x = 0.25
			for index, value in pairs(data) do
				local state = self.state
				n =n + 1
				total = total + value
				delay((n-1)/6, function()
					x = x + 1
					table.insert(self.state.paycheckFrames, Roact.createElement("TextLabel", {
						Size = UDim2.new(.925,0,.1,0),
						Position = UDim2.new(0.5,0,.15 + .1*(x-1),0),
						AnchorPoint = Vector2.new(.5,0),
						Text = index..": $"..value,
						TextXAlignment = "Left",
						TextScaled = true,
						BackgroundTransparency = 1,
						Font = "SciFi",
						TextStrokeTransparency = .8,
						TextColor3 = Color3.new(1,1,1)-- Color3.new(.1,.8,1),
					}))
					self:setState(state)
				end)
			end
			delay(((n-1)/6) + .25, function()
				local state = self.state
				table.insert(self.state.paycheckFrames, Roact.createElement("TextLabel", {
					Size = UDim2.new(.925,0,.1,0),
					Position = UDim2.new(0.5,0,.15 + .1*(x),0),
					AnchorPoint = Vector2.new(.5,0),
					Text = "TOTAL: "..total,
					TextXAlignment = "Left",
					TextScaled = true,
					BackgroundTransparency = 1,
					Font = "SciFi",
					TextStrokeTransparency = .5,
					TextColor3 = Color3.new(1,.1,.1)-- Color3.new(.1,.8,1),
				}))
				self:setState(state)
			end)
		end)
	end)
end

function Paycheck:render()
	return Frame({
		size = UDim2.new(0.6,0,0.35,0),
		position = UDim2.new(.5,0,.5,0),
		visible = self.state.visible,
		anchorPoint = Vector2.new(.5,.5),
		aspectRatio = 2,
		closeCallback = function()
			self:setState({visible = false})
		end,
	}, {
		TextLabel = Roact.createElement("TextLabel", {
			Size = UDim2.new(.95,0,.1,0),
			Position = UDim2.new(.5,0,0.025,0),
			BackgroundTransparency = 1,
			TextScaled = true,
			Text = "INTERGALACTIC BANK",
			TextXAlignment = "Left",
			Font = "SciFi",
			TextStrokeTransparency = 1,
			TextColor3 = Color3.new(1,1,1),
			ZIndex = 2,
			AnchorPoint = Vector2.new(.5,0),
		}),
		YesButton = Roact.createElement("TextButton", {
			Size = UDim2.new(.25,0,.1,0),
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundColor3 = StyleConstants.YES_COLOR,
			BorderSizePixel = 0,
			TextScaled = true,
			Font = "SciFi",
			TextColor3 = Color3.new(1,1,1),
			Text = "CLOSE",
			Position = UDim2.new(.5,0,.9,0),
			[Roact.Event.Activated] = function()
				self:setState({visible = false})
			end,
		}),
		unpack(self.state.paycheckFrames)
	})
end

return Paycheck
