local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TweenService = game:GetService("TweenService")

local Roact = import "Roact"

local Icon = Roact.PureComponent:extend("Icons")

function Icon:init(info)
	self.info = info

	self:setState({
		toggled = false
	})

	self.ref = Roact.createRef()
end

local function onPressed(ui, isToggled)
	local tweenInfo = TweenInfo.new(
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
	if isToggled then
		goalSize = UDim2.new(.75,0,.75,0)
	end
	local goalColor = Color3.new(1,1,1)
	if isToggled then
		goalColor = Color3.new(.8,.8,.8)
	end
	local tween = TweenService:Create(ui,tweenInfo, {ImageColor3 = goalColor})
	tween:Play()
	tween = TweenService:Create(ui,tweenInfo, {Size = goalSize})
	tween:Play()
	--[[local tween = TweenService:Create(ui,tweenInfo, {Rotation = goalRotation})
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
			Image = "rbxassetid://3678512862",
			SizeConstraint = "RelativeYY",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(.5,.5),
			ImageColor3 = Color3.new(1,1,1),
			Position = UDim2.new(.5,0,.5,0),
			[Roact.Ref] = self.ref,
			[Roact.Event.Activated] = function()
				self:setState({
					toggled = not self.state.toggled
				})
				Messages:send("PlaySoundClient", "ButtonNew")
				self.info.pressed()
				onPressed(self.ref.current, self.state.toggled)
			end,
		}, {
			UiPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0.2,0),
				PaddingRight = UDim.new(0.2,0),
				PaddingTop = UDim.new(0.2,0),
				PaddingBottom = UDim.new(0.2,0),
			}),
			Icon = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1,0,1,0),
				Image = self.info.icon,
				BackgroundTransparency = 1,
				Active = false
			})
		}),
	})
end

return Icon
