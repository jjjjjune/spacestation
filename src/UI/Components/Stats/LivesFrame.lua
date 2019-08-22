local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"

return function(n)
	local children = {}
	for i = 1, n do
		table.insert(children, Roact.createElement("ImageLabel", {
			SizeConstraint = "RelativeYY",
			Image = "rbxassetid://3698509036",
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
		}))
	end
	table.insert(children, Roact.createElement("UIListLayout", {
		HorizontalAlignment = "Left",
		VerticalAlignment = "Center",
		FillDirection = "Horizontal"
	}))

	return Roact.createElement("Frame", {
		Size = UDim2.new(1,0,.75,0),
		Position = UDim2.new(0,0,1,6),
		BackgroundTransparency = 1,
	},children)
end
