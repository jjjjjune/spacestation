local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"
local Notifications = Roact.PureComponent:extend("Notifications")
local Frame = import "UI/Components/Frame"
local StyleConstants = import "Shared/Data/StyleConstants"

local notifications = {}

local notificationRefs = {}

local NOTIFICATION_TIME = 10

function Notifications:init()
	self.mainFrameRef = Roact.createRef()
	Messages:hook("Notify", function(text)
		local timestamp = tick()
		table.insert(notifications, {
			text = text,
			["time"] = timestamp,
		})
		notificationRefs[timestamp] = Roact.createRef()
		self:setState({})
		local ref = self.mainFrameRef.current
		ref:TweenPosition(UDim2.new(0,0,.5,0) + UDim2.new(0,0,0,-5), "Out", "Quad", .1, true, function()
			ref:TweenPosition(UDim2.new(0,0,.5,0) + UDim2.new(0,0,0,5), "Out", "Quad", .1, true)
		end)
	end)
	game:GetService("RunService").Stepped:connect(function()
		debug.profilebegin("notify")
		self:setState({})
		debug.profileend()
	end)
end

function Notifications:render()
	local notificationChildren = {}
	table.insert(notificationChildren, Roact.createElement("UIListLayout", {
		HorizontalAlignment = "Left",
		VerticalAlignment = "Bottom",
		Padding = UDim.new(0,10),
	}))
	for i, notification in pairs(notifications) do
		local timeSince = tick() - notification.time
		if timeSince < NOTIFICATION_TIME then
			table.insert(notificationChildren, Frame(
				{
					size = UDim2.new(.95,0,.075,0),
					position = UDim2.new(0.5,0,0,0),
					visible = true,
					anchorPoint = Vector2.new(0,0.5),
					aspectRatio = 4,
					closeCallback = function()
						self:setState({visible = false})
					end,
					[Roact.Ref] = notificationRefs[notification.time]
				},
				{Text = Roact.createElement("TextLabel", {
					Size = UDim2.new(.9,0,.8,0),
					Position = UDim2.new(0.5,0,.15,0),
					BackgroundTransparency = 1,
					BackgroundColor3 = StyleConstants.CLOSE_COLOR,
					TextScaled = true,
					BorderSizePixel = 0,
					Text = notification.text,
					Font = "SourceSans",
					TextStrokeTransparency = 1,
					TextStrokeColor3 = Color3.new(0,0,0),
					TextColor3 = Color3.new(0,0,0),
					ZIndex = 2,
					AnchorPoint = Vector2.new(.5,0),
				})}
			))
		else
			Notifications[i] = nil
		end
	end
	return Roact.createElement("Frame", {
		Size = UDim2.new(.15,0,.95,0),
		Position = UDim2.new(0,0,0.5,0),
		AnchorPoint = Vector2.new(0,0.5),
		BackgroundTransparency = 1,
		[Roact.Ref] = self.mainFrameRef
	}, notificationChildren)
end

return Notifications
