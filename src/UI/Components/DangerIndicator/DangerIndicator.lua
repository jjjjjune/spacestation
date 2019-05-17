local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })

local StyleConstants = import "Shared/Data/StyleConstants"
local WorldConstants = import "Shared/Data/WorldConstants"

local DangerIndicator = Roact.PureComponent:extend("DangerIndicator")

function DangerIndicator:init()
	self.visible = false
	spawn(function()
		while wait() do self:setState({}) end
	end)
end

function DangerIndicator:render()
	local visible = self.visible
	return Roact.createElement("TextLabel", {
		AnchorPoint = Vector2.new(.5,0),
		Size = UDim2.new(.6,0,.1,0),
		Position = UDim2.new(.50,0,0,0),
		TextXAlignment = "Center",
		TextScaled = true,
		BackgroundTransparency =1,
		TextColor3 = Color3.new(1,1,1),
		Font = StyleConstants.FONT_BOLD,
		Text = WorldConstants.COMBATLOG_MESSAGE,
		Visible = visible,
	})
end

function DangerIndicator:didUpdate()
	local lastHit = _G.Data and  _G.Data.lastHit
	if lastHit then
		if time() - lastHit < WorldConstants.COMBAT_LOG_TIME then
			self.visible = true
		else
			self.visible = false
		end
	else
		self.visible = false
	end
end

local function mapStateToProps(state, props)
	return {
	}
end

return Connect(mapStateToProps)(DangerIndicator)

