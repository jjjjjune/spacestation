local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local UserInputService = game:GetService("UserInputService")

local Roact = import "Roact"
local Icon = import "../Icon"

local Icons = Roact.PureComponent:extend("Icons")

local IconList = import "Shared/Data/IconList"

function Icons:init()

end

function Icons:render()
	local scale =  1.25
	if UserInputService.TouchEnabled then
		scale = 1
	end
	local childFrames = {}

	for _, iconData in pairs(IconList) do
		childFrames[#childFrames+1] = Roact.createElement(Icon, iconData)
	end

	childFrames[#childFrames+1] = Roact.createElement("UIListLayout", {
		FillDirection = "Horizontal",
		HorizontalAlignment = "Center",
		VerticalAlignment = "Center",
		Padding = UDim.new(0,8),
	})

	childFrames[#childFrames+1] = Roact.createElement("UIAspectRatioConstraint", {
		AspectRatio = 12,
	})

	return Roact.createElement("Frame", {
		Size = UDim2.new(.5,0,.04*scale,0),
		Position = UDim2.new(.5,0,0.04*scale,0),
		AnchorPoint = Vector2.new(.5,0),
		BackgroundTransparency = 1,
	}, childFrames)
end

return Icons
