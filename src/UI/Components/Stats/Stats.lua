local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local UserInputService = game:GetService("UserInputService")

local Roact = import "Roact"
local Bar = import "../Bar"

local Stats = Roact.PureComponent:extend("Stats")

local playerStats

function Stats:init()
	Messages:hook("UpdateStats", function(stats)
		playerStats = stats
		self:setState({})
	end)
end

function Stats:render()
	if playerStats then
		local n = #playerStats
		local size = UDim2.new(.5/n,0,1,0)

		local childFrames = {}

		for x = 1, #playerStats do
			local stat = playerStats[x]
			childFrames[x] = Roact.createElement(Bar, {
				size = size,
				primaryColor = stat.color,
				visible = true,
				amount = stat.current,
				maxAmount = stat.max,
				icon = stat.icon,
			})
		end

		childFrames[#childFrames+1] = Roact.createElement("UIListLayout", {
			FillDirection = "Horizontal",
			HorizontalAlignment = "Center",
			VerticalAlignment = "Center",
			Padding = UDim.new(0,8),
		})
		childFrames[#childFrames+1] = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 14,
		})


		local scale =  1.25
		if UserInputService.TouchEnabled then
			scale = 1
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(.5,0,.03*scale,0),
			Position = UDim2.new(.5,0,0,6),
			AnchorPoint = Vector2.new(.5,0),
			BackgroundTransparency = 1,
		}, childFrames)
	end
end

return Stats
