local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"
local Notifications = Roact.PureComponent:extend("Notifications")
local Frame = import "UI/Components/Frame"
local StyleConstants = import "Shared/Data/StyleConstants"

local notifications = {
}

local NOTIFICATION_TIME = 10

function Notifications:init()
	spawn(function()
		while wait() do self:setState({}) end
	end)
	Messages:hook("Notify", function(text)
		table.insert(notifications, {
			text = text,
			time = time(),
		})
	end)
end

function Notifications:render()
	local notificationChildren = {}
	table.insert(notificationChildren, Roact.createElement("UIListLayout", {
		HorizontalAlignment = "Center",
		VerticalAlignment = "Bottom",
		Padding = UDim.new(0,10),
	}))
	for i, notification in pairs(notifications) do
		if time() - notification.time < NOTIFICATION_TIME then
			table.insert(notificationChildren, Frame(
				{
					size = UDim2.new(1,0,.075,0),
					--position = UDim2.new(0.5,0,0.5,0),
					visible = true,
					anchorPoint = Vector2.new(0,0),
					aspectRatio = 4,
					closeCallback = function()
						self:setState({visible = false})
					end,
				},
				{Text = Roact.createElement("TextLabel", {
					Size = UDim2.new(.9,0,.8,0),
					Position = UDim2.new(0.5,0,.15,0),
					BackgroundTransparency = 1,
					BackgroundColor3 = StyleConstants.CLOSE_COLOR,
					TextScaled = true,
					BorderSizePixel = 0,
					Text = notification.text,
					Font = "SciFi",
					TextStrokeTransparency = .9,
					TextStrokeColor3 = Color3.new(0,0,0),
					TextColor3 = Color3.new(1,1,1),
					ZIndex = 2,
					AnchorPoint = Vector2.new(.5,0),
				})}
			))
		else
			Notifications[i] = nil
		end
	end
	return Roact.createElement("Frame", {
		Size = UDim2.new(.14,0,.975,0),
		Position = UDim2.new(0,0,0,20),
		AnchorPoint = Vector2.new(0,0),
		BackgroundTransparency = 1,
	}, notificationChildren)
end

return Notifications
