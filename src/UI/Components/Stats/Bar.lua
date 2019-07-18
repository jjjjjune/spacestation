local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"

local Bar = Roact.PureComponent:extend("Bar")

function Bar:init(suppliedProps)
	self.size = suppliedProps.size
	self.primaryColor = suppliedProps.primaryColor
	self.position = suppliedProps.position
	self.visible = suppliedProps.visible
	self.icon = suppliedProps.icon
end

function Bar:render(props)
	local visible = self.props.visible
	if visible == nil then
		visible = true
	end
	return Roact.createElement("Frame", {
		Size = self.size,
		BackgroundColor3 = self.primaryColor,
		BorderSizePixel = 0,
		Position = self.position,
		Visible = visible,
	}, {
		Icon = Roact.createElement("ImageLabel", {
			Size = UDim2.new(1,0,1,0),
			SizeConstraint = "RelativeYY",
			BackgroundTransparency = 1,
			BackgroundColor3 = self.primaryColor,
			Image = self.icon
		}),
		ActualBar = Roact.createElement("Frame", {
			Size = UDim2.new(math.max(0,self.props.amount/self.props.maxAmount), 0, 1,0),
			BackgroundColor3 = Color3.new(1,1,1),
			BorderSizePixel = 0,
			BackgroundTransparency = .8
		}),
		ActualBarHighlight = Roact.createElement("Frame", {
			Size = UDim2.new(0, 4, 1,0),
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.new(1,1,1),
			BackgroundTransparency = .95,
			BorderSizePixel = 0,
			Position = UDim2.new(math.max(0,self.props.amount/self.props.maxAmount),0,0,0),
			ZIndex = 4,
		}),
	})
end

return Bar
