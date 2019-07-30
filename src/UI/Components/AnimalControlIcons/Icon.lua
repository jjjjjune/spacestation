local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local Roact = import "Roact"

local Icon = Roact.PureComponent:extend("Icons")

function Icon:init(props)
	self.ref = Roact.createRef()
end

function Icon:didUpdate(oldProps, props)

end

function Icon:willUnmount()

end

function Icon:didMount()

end

local function onPressed(ui)

end

function Icon:render()
	local alwaysOnTop = false
	local icon = "rbxassetid://3560965044"
	if self.props.following then
		icon = "rbxassetid://3560965131"
	end
	return Roact.createElement("BillboardGui", { -- holder baby
		Size = UDim2.new(1.5,0,1.5,0),
		Active = true,
		StudsOffset = Vector3.new(0,2,1),
		AlwaysOnTop = alwaysOnTop,
		Adornee = self.props.adornee,
		MaxDistance = 40,
	}, {
		Inside = Roact.createElement("ImageButton", {
			Size = UDim2.new(1,0,1,0),
			Image = icon,
			SizeConstraint = "RelativeYY",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(.5,.5),
			Position = UDim2.new(.5,0,.5,0),
			[Roact.Ref] = self.ref,
			[Roact.Event.Activated] = function()
				Messages:send("PlaySoundClient", "ButtonNew")
				onPressed(self.ref.current)
				Messages:sendServer("ToggleFollowing", self.props.adornee.Parent)
			end,
			ZIndex = 2,
		})
	})
end

return Icon
