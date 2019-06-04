local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })
local Bar = import "../Bar"

local StyleConstants = import "Shared/Data/StyleConstants"
local StatConstants = import "Shared/Data/StatConstants"
local Messages = import "Shared/Utils/Messages"

local HungerThirst = Roact.PureComponent:extend("HungerThirst")

function HungerThirst:init(props)
	self.props = props
	self:setState(function(state)
		return {
			lastStaminaChange = time() - 100,
			stamina = 100
		}
	end)
	Messages:hook("SetLastClimb", function(t)
		self:setState(function(state)
			return {
				lastStaminaChange = t
			}
		end)
	end)
	Messages:hook("SetStamina", function(s)
		self:setState(function(state)
			return {
				stamina = s
			}
		end)
	end)
end

function HungerThirst:render()
	local userId = tostring(game.Players.LocalPlayer.UserId)
	local stats = self.props.playerStats[userId]
--[[
	Text = "hunger: "..(stats.hunger or"nil").." thirst: "..(stats.thirst or"nil"),
			Visible = true,
			Size = UDim2.new(0,100,0,100),
			TextScaled = true,
]]
	local health = stats.health
	local maxHealth = stats.maxHealth

	if stats then
		local visible = ((time() - self.state.lastStaminaChange) < 10) or false
		return Roact.createElement("Frame", {
			Size = UDim2.new(.2,0,.1,0),
			Position = UDim2.new(.5,0,1,0),
			AnchorPoint = Vector2.new(.5,1),
			BackgroundTransparency =1 ,
		}, {
			healthBar = Roact.createElement(Bar, {
				amount = health,
				maxAmount = maxHealth,
				size = UDim2.new(1,0,.4,0),
				text = "HEALTH",
				primaryColor = StyleConstants.HEALTH_COLOR,
				position = UDim2.new(0,0,.5,0),
			}),
			hungerBar = Roact.createElement(Bar, {
				amount = stats.hunger,
				maxAmount = 100,
				size = UDim2.new(.35,0,.4,0),
				text = "HUNGER",
				primaryColor = StyleConstants.HUNGER_COLOR,
				position = UDim2.new(0,0,0,0),
			}),
			thirstBar = Roact.createElement(Bar, {
				amount = stats.thirst,
				maxAmount = 100,
				size = UDim2.new(.35,0,.4,0),
				text = "THIRST",
				primaryColor = StyleConstants.THIRST_COLOR,
				position = UDim2.new(0.65,0,0,0),
			}),
			staminaBar = Roact.createElement(Bar, {
				amount = self.state.stamina,
				maxAmount = 100,
				size = UDim2.new(1,0,.1,0),
				text = "STAMINA",
				primaryColor = Color3.fromRGB(136,222,113),
				position = UDim2.new(0,0,-.25,0),
				visible = visible
			}),
			middleBar = Roact.createElement("Frame", {
				Size = UDim2.new(.15,0,.4,0),
				Position = UDim2.new(.5,0,0,0),
				AnchorPoint = Vector2.new(.5,0),
				BorderSizePixel = 0,
				BackgroundColor3 = StyleConstants.WINDOW_BG,
			}, {
				Shadow = Roact.createElement("Frame", {
					Size = UDim2.new(1,0,0,4),
					BorderSizePixel = 0,
					BackgroundColor3 = StyleConstants.STROKE_COLOR,
					Position = UDim2.new(0,0,1,0),
				}),
				Text = Roact.createElement("TextLabel", {
					Font = StyleConstants.FONT_BOLD,
					Text = math.floor(stats.timeAlive/1800),
					BorderSizePixel = 0,
					Size = UDim2.new(1,0,1,0),
					ZIndex = 3,
					BackgroundTransparency =1,
					TextScaled = true,
					TextXAlignment = "Center",
					TextColor3 = Color3.new(1,1,1)
				}),
				TextShadow = Roact.createElement("TextLabel", {
					Font = StyleConstants.FONT_BOLD,
					Text = math.floor(stats.timeAlive/StatConstants.DAY),
					BorderSizePixel = 0,
					Size = UDim2.new(1,0,1,0),
					Position = UDim2.new(0,0,0,2),
					ZIndex = 2,
					BackgroundTransparency =1,
					TextScaled = true,
					TextXAlignment = "Center",
					TextColor3 = Color3.new(.2,.2,.3)
				}),
			}),
		})
	end
end

local function mapStateToProps(state, props)
	return {
		playerStats = state.playerStats,
	}
end

return Connect(mapStateToProps)(HungerThirst)
