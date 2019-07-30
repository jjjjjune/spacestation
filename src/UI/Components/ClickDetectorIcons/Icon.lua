local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TweenService = game:GetService("TweenService")

local Roact = import "Roact"

local Icon = Roact.PureComponent:extend("Icons")

function Icon:init(props)

	self:setState({})

	self.ref = Roact.createRef()
end

function Icon:didUpdate(oldProps, props)

end

function Icon:willUnmount()
	self.connect:disconnect()
end

function Icon:didMount()
	self.connect = game:GetService("RunService").RenderStepped:connect(function()
		self:setState({})
	end)
end

local function onPressed(ui)

end

function Icon:render()
	local camera = workspace.CurrentCamera
	local vector, _ = camera:WorldToScreenPoint(self.props.detector.Parent.Position)
	local col = self.props.detector.Parent.BrickColor.Color
	local alwaysOnTop = false
	local player = game.Players.LocalPlayer
	if player.Character then
		local root = player.Character.PrimaryPart
		if root then
			local distance = (root.Position - self.props.detector.Parent.Position).magnitude
			if distance < 11 then
				if self.props.detector.Parent.Name ~= "Lock" then
					alwaysOnTop = true
				else
					if distance < 6 then
						alwaysOnTop = true
					end
				end
			end
		end
	end
	return Roact.createElement("BillboardGui", { -- holder baby
		Size = UDim2.new(1.5,0,1.5,0),
		Active = true,
		--StudsOffset = Vector3.new(0,2,1),
		StudsOffset = Vector3.new(0,0,0),
		AlwaysOnTop = alwaysOnTop,
		--StudsOffsetWorldSpace = Vector3.new(0,0,-1),
		--SizeConstraint = "RelativeYY",
		--AnchorPoint = Vector2.new(.5,.5),
		--BackgroundTransparency = 1,
		--Position = UDim2.new(0, vector.X, 0, vector.Y),
		Adornee = self.props.detector.Parent
	}, {
		Inside = Roact.createElement("ImageButton", {
			Size = UDim2.new(1,0,1,0),
			Image = "rbxassetid://3540399251",
			SizeConstraint = "RelativeYY",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(.5,.5),
			ImageColor3 = Color3.new(col.r + .2,col.g + .2,col.b + .2),
			Position = UDim2.new(.5,0,.5,0),
			[Roact.Ref] = self.ref,
			[Roact.Event.Activated] = function()
				Messages:send("PlaySoundClient", "ButtonNew")
				onPressed(self.ref.current)
				Messages:sendServer("PlayerClicked", self.props.detector)
			end,
			ZIndex = 2,
		})
	})
end

return Icon
