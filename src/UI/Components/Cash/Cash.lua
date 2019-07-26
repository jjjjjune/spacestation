local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"
local Cash = Roact.PureComponent:extend("Cash")

function Cash:init()
	self.state = {cash = 0}
	Messages:hook("PlayerDataSet", function(stat, value)
		if stat == "cash" then
			self:setState({
				["cash"] = value
			})
		end
	end)
	game:GetService("RunService").Stepped:connect(function()
		self:setState({
			["cash"] = _G.Data["cash"] or 0
		})
	end)
end

function Cash:render()
	return Roact.createElement("TextLabel", {
		Size = UDim2.new(.1,0,0,30),
		Position = UDim2.new(.5,0,0,90),
		AnchorPoint = Vector2.new(.5,0),
		BackgroundTransparency = 1,
		Text = "MONEY: " ..self.state.cash,
		TextScaled = true,
		TextXAlignment = "Center",
		Font = "SciFi",
		TextColor3 = Color3.fromRGB(12,173,76),
		TextStrokeColor3 = Color3.new(.05,.05,.1),
		TextStrokeTransparency = .8
	})
end

return Cash
