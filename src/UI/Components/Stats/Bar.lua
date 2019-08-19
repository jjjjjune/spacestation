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
		BackgroundTransparency = 1,
		Position = self.position,
		Visible = visible,
		AnchorPoint = Vector2.new(0,.5)
	},{
		Icon = Roact.createElement("ImageLabel", {
			Size = UDim2.new(.2,0,.2,0),
			Position = UDim2.new(0,0,.5,0),
			AnchorPoint = Vector2.new(.5,.5),
			SizeConstraint = "RelativeXX",
			BackgroundTransparency = 1,
			BackgroundColor3 = self.primaryColor,
			Image = self.icon,
			ZIndex = 4,
		}),
		BarFrame = Roact.createElement("ImageLabel", {
			Size = UDim2.new(.85,0,1,0),
			Position = UDim2.new(.15,0,0,0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Image = "rbxassetid://3683650768",--rbxassetid://3677918992",
			ScaleType = "Slice",
			SliceCenter = Rect.new(512,512,512,512),
			ImageColor3 = Color3.new(0,0,0),
			ZIndex = 5,
		}, {
			Padding  = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0,2),
				PaddingRight = UDim.new(0,2),
				PaddingTop = UDim.new(0,1),
				PaddingBottom = UDim.new(0,1),
			}),
			Design = Roact.createElement("ImageLabel", {
				Size = UDim2.new(math.max(0,self.props.amount/self.props.maxAmount), 0, 1,0),
				ClipsDescendants = true,
				BackgroundColor3 = self.secondaryColor,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				Image = "rbxassetid://3677447246",
				ImageColor3 = self.secondaryColor,
				ScaleType = "Crop",
				ZIndex = 3,
			}, {
				ActualBar2 = Roact.createElement("ImageLabel", {
					Size = UDim2.new(0,200,1,0),
					BackgroundColor3 = self.primaryColor,
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Image = "rbxassetid://3679520921",
					ImageColor3 =  self.primaryColor,
					ScaleType = "Crop",
					ZIndex = 4,
					--[Roact.Ref] = self.rotationRef
				}),
			}),
		})
	})
end

return Bar
