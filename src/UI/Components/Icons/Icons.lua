local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"
local Icon = import "../Icon"

local Icons = Roact.PureComponent:extend("Icons")

local IconList = import "Shared/Data/IconList"

function Icons:init()

end

function Icons:render()
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

	return Roact.createElement("Frame", {
		Size = UDim2.new(.5,0,0,40),
		Position = UDim2.new(.5,0,0,44),
		AnchorPoint = Vector2.new(.5,0),
		BackgroundTransparency = 1,
	}, childFrames)
end

return Icons
