local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local StyleConstants = import "Shared/Data/StyleConstants"

local Bar = Roact.PureComponent:extend("Bar")

function Bar:init(suppliedProps)
	self.text = suppliedProps.text
	self.size = suppliedProps.size
	self.bgColor = suppliedProps.bgColor
	self.primaryColor = suppliedProps.primaryColor
	self.position = suppliedProps.position
	self.visible = suppliedProps.visible
end

function Bar:render(props)
	local visible = self.props.visible
	if visible == nil then
		visible = true
	end
	return Roact.createElement("Frame", {
		Size = self.size,
		BackgroundColor3 = StyleConstants.WINDOW_BG,
		BorderSizePixel = 0,
		Position = self.position,
		Visible = visible
	}, {
		TextHolder = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0, 1, 0),
		}, {
			--[[Text = Roact.createElement("TextLabel", {
				Font = StyleConstants.FONT_BOLD,
				Text = self.text..": "..self.props.amount.."/"..self.props.maxAmount,
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,1,0),
				ZIndex = 3,
				BackgroundTransparency =1,
				TextScaled = true,
				TextXAlignment = "Left",
				TextColor3 = Color3.new(1,1,1)
			}),
			TextShadow = Roact.createElement("TextLabel", {
				Font = StyleConstants.FONT_BOLD,
				Text = self.text..": "..self.props.amount.."/"..self.props.maxAmount,
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,2),
				ZIndex = 2,
				BackgroundTransparency =1,
				TextScaled = true,
				TextXAlignment = "Left",
				TextColor3 = Color3.new(.2,.2,.3)
			}),--]]
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0,2),
				PaddingRight = UDim.new(.1,0),
				PaddingTop = UDim.new(.1,0),
				PaddingBottom = UDim.new(.1,0),
			})
		}),
		ActualBar = Roact.createElement("Frame", {
			Size = UDim2.new(math.max(0,self.props.amount/self.props.maxAmount), 0, 1,0),
			BackgroundColor3 = self.primaryColor,
			BorderSizePixel = 0,
		}),
		ActualBarHighlight = Roact.createElement("Frame", {
			Size = UDim2.new(0, 6, 1,0),
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.new(1,1,1),
			BackgroundTransparency = .8,
			BorderSizePixel = 0,
			Position = UDim2.new(math.max(0,self.props.amount/self.props.maxAmount),0,0,0),
			ZIndex = 4,
		}),
		Shadow = Roact.createElement("Frame", {
			Size = UDim2.new(1,0,0,4),
			BorderSizePixel = 0,
			BackgroundColor3 = StyleConstants.STROKE_COLOR,
			Position = UDim2.new(0,0,1,0),
		})
	})
end

return Bar
