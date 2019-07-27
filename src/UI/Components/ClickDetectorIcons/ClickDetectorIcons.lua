local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"

local ClickDetectorIcons = Roact.PureComponent:extend("ClickDetectorIcons")
local Icon = import "../Icon"

function ClickDetectorIcons:init()
	Messages:hook("SetNearbyDetectors", function(detectors)
		self:setState({
			["detectors"] = detectors
		})
	end)
	self:setState({
		detectors = {}
	})
end

function ClickDetectorIcons:willUnmount()
	self.connect:disconnect()
end

function ClickDetectorIcons:didMount()

end

function ClickDetectorIcons:render()
	local children = {}
	for i, detector in pairs(self.state.detectors) do
		table.insert(children, Roact.createElement(Icon, {
			["detector"] = detector,
		}))
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
	}, children)
end

return ClickDetectorIcons
