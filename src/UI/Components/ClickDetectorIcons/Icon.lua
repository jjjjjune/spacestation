local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TweenService = game:GetService("TweenService")

local Roact = import "Roact"

local Icon = Roact.PureComponent:extend("Icons")

function Icon:init(detector)
	self:setState({
		detector = detector
	})

	self.ref = Roact.createRef()
end

local function onPressed(ui)
	--[[local tweenInfo = TweenInfo.new(
		.2,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out,
		0
	)
	local goalRotation = 0
	if isToggled then
		goalRotation = 35
	end
	local goalSize = UDim2.new(1,0,1,0)
	if not isToggled then
		goalSize = UDim2.new(.75,0,.75,0)
	end
	local goalColor = Color3.new(.9,1,.95,0)
	if not isToggled then
		goalColor = Color3.new(.5,.5,.5)
	end
	local tween = TweenService:Create(ui,tweenInfo, {ImageColor3 = goalColor})
	tween:Play()
	tween = TweenService:Create(ui,tweenInfo, {Size = goalSize})
	tween:Play()
	tween = TweenService:Create(ui,tweenInfo, {Rotation = goalRotation})
	tween:Play()--]]
end

function Icon:render()
	return Roact.createElement("Frame", { -- holder baby
		Size = UDim2.new(1,0,1,0),
		SizeConstraint = "RelativeYY",
		AnchorPoint = Vector2.new(.5,.5),
		BackgroundTransparency = 1,
	}, {
		Inside = Roact.createElement("ImageButton", {
			Size = UDim2.new(1,0,1,0),
			Image = "rbxassetid://3540399251",
			SizeConstraint = "RelativeYY",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(.5,.5),
			ImageColor3 = Color3.new(.5,.5,.5),
			Position = UDim2.new(.5,0,.5,0),
			[Roact.Ref] = self.ref,
			[Roact.Event.Activated] = function()
				Messages:send("PlaySoundClient", "ButtonNew")
				onPressed(self.ref.current)
			end,
		})
	})
end

return Icon
