local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"

local Bar = Roact.PureComponent:extend("Bar")

local function changeBrightness(color, percent)
	local h, s, v = Color3.toHSV(color)

    return Color3.fromHSV(h, s, math.clamp(v+(v*percent/100), 0, 1))
end

function Bar:init(suppliedProps)
	self.size = suppliedProps.size
	self.primaryColor = suppliedProps.primaryColor
	self.position = suppliedProps.position
	self.visible = suppliedProps.visible
	self.icon = suppliedProps.icon
	self.secondaryColor = suppliedProps.secondaryColor
end

function Bar:render(props)
	local visible = self.props.visible
	if visible == nil then
		visible = true
	end
	--local bright = changeBrightness(self.primaryColor, 80)
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
			Image = self.icon,
			ZIndex = 4,
		}),
		ActualBar = Roact.createElement("Frame", {
			Size = UDim2.new(math.max(0,self.props.amount/self.props.maxAmount), 0, 1,0),
			BackgroundColor3 = self.secondaryColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0
		}),
	})
end

return Bar
