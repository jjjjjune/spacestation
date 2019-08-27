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
		spawn(function()
			self.state.paycheckFrames = {}
			self.state.visible = true
			local total = 0
			local n = 0
			local x = 0.25
			local divisor = 3
			for index, value in pairs(data) do
				n =n + 1
				total = total + value
				delay((n-1)/divisor, function()
					local state = self.state
					x = x + 1
					table.insert(self.state.paycheckFrames, Roact.createElement("TextLabel", {
						Size = UDim2.new(.925,0,.075,0),
						Position = UDim2.new(0.5,0,.2 + .085*(x-1),0),
						AnchorPoint = Vector2.new(.5,0),
						Text = index..": $"..value,
						TextXAlignment = "Left",
						TextScaled = true,
						BackgroundTransparency = 1,
						Font = "SciFi",
						TextStrokeTransparency = 1,
						TextColor3 = Color3.new(1,1,1),--Color3.new(.1,.8,1),
						ZIndex = 2,
					}))
					self:setState(state)
					Messages:send("PlaySoundClient", "UnlockFast")
				end)
			end
			delay((n-1)/divisor + .75, function()
				local state = self.state
				table.insert(self.state.paycheckFrames, Roact.createElement("TextLabel", {
					Size = UDim2.new(.925,0,.15,0),
					Position = UDim2.new(0.5,0,.2 + .085*(x),0),
					AnchorPoint = Vector2.new(.5,0),
					Text = "TOTAL: "..total,
					TextXAlignment = "Left",
					TextScaled = true,
					BackgroundTransparency = 1,
					Font = "SciFi",
					TextStrokeTransparency = 1,
					TextColor3 = Color3.new(1,.5,.5),-- Color3.new(.1,.8,1),
					ZIndex = 3,
				}))
				table.insert(self.state.paycheckFrames, Roact.createElement("TextLabel", {
					Size = UDim2.new(.925,0,.15,0),
					Position = UDim2.new(0.5,-2,.2 + .085*(x),0),
					AnchorPoint = Vector2.new(.5,0),
					Text = "TOTAL: "..total,
					TextXAlignment = "Left",
					TextScaled = true,
					BackgroundTransparency = 1,
					Font = "SciFi",
					TextStrokeTransparency = 1,
					TextColor3 = Color3.new(.1,.1,.1),
					ZIndex = 2,
				}))
				self:setState(state)
				Messages:send("PlaySoundClient", "UnlockMedium")
			end)
		end)
	end)
end

function Paycheck:render()
	return Frame({
		size = UDim2.new(0.8,0,0.45,0),
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
		TextLabel2 = Roact.createElement("TextLabel", {
			Size = UDim2.new(.95,0,.1,0),
			Position = UDim2.new(.5,0,0.025,0),
			BackgroundTransparency = 1,
			TextScaled = true,
			Text = "-xorGYyu IBxl unUM-",
			TextXAlignment = "Right",
			Font = "SciFi",
			TextStrokeTransparency = 1,
			TextTransparency = .5,
			TextColor3 = Color3.new(1,1,1),
			ZIndex = 2,
			AnchorPoint = Vector2.new(.5,0),
		}),
		Logo = Roact.createElement("ImageLabel", {
			Size = UDim2.new(.5,0,.5,0),
			SizeConstraint = "RelativeYY",
			Position = UDim2.new(.8,0,.5,0),
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3566558009",
		}),
		YesButton = Roact.createElement("TextButton", {
			Size = UDim2.new(.35,0,.15,0),
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundColor3 = StyleConstants.TAB_COLOR,
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
