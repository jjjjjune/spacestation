local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local UserInputService = game:GetService("UserInputService")

local Icons = import "UI/Components/Icons/Icons"

local Roact = import "Roact"
local Bar = import "../Bar"
local LivesFrame = import "../LivesFrame"

local Stats = Roact.PureComponent:extend("Stats")

local playerStats

function Stats:init()
	self:setState({
		cash = 0,
		lives = 0,
	})
	Messages:hook("UpdateStats", function(stats)
		playerStats = stats
		self:setState({})
	end)
	Messages:hook("PlayerDataSet", function(stat, value)
		if stat == "cash" then
			self:setState({
				["cash"] = value
			})
		end
	end)
	Messages:hook("NotifyLivesLeft", function(lives)
		self:setState({
			lives = lives,
		})
	end)
	game:GetService("RunService").Stepped:connect(function()
		self:setState({
			["cash"] = _G.Data["cash"] or 0
		})
	end)
end

function Stats:render()
	if playerStats then
		local n = #playerStats
		local size = UDim2.new(.5/n,0,.5,0)

		local childFrames = {}

		for x = 1, #playerStats do
			local stat = playerStats[x]
			childFrames[x] = Roact.createElement(Bar, {
				size = size,
				primaryColor = stat.color,
				visible = true,
				amount = stat.current,
				maxAmount = stat.max,
				icon = stat.icon,
				secondaryColor = stat.secondaryColor
			})
		end

		childFrames[#childFrames+1] = Roact.createElement("UIListLayout", {
			FillDirection = "Horizontal",
			HorizontalAlignment = "Left",
			VerticalAlignment = "Center",
			Padding = UDim.new(.035,0),
		})

		childFrames[#childFrames+1] = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0,22),
			PaddingRight = UDim.new(0,4),
			PaddingTop = UDim.new(0,4),
			PaddingBottom = UDim.new(0,4),
		})

		childFrames[#childFrames+1] = Roact.createElement("TextLabel", {
			Size = UDim2.new(.1,0,1,0),
			BackgroundTransparency = 1,
			TextScaled = true,
			Text = "$ "..self.state.cash,
			Font = "SourceSansBold",
			TextXAlignment = "Left",
		})

		childFrames[#childFrames+1] = Roact.createElement(Icons, {})

		--[[childFrames[#childFrames+1] = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 14,
		})--]]


		local scale =  1.2
		if UserInputService.TouchEnabled then
			scale = 1
		end
		--childFrames
		return Roact.createElement("ImageLabel", {
			Size = UDim2.new(.4,0,0,80*scale),
			Position = UDim2.new(.5,0,0,6),
			AnchorPoint = Vector2.new(.5,0),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3677918992",
			ScaleType = "Slice",
			SliceCenter = Rect.new(512,512,512,512),
			ImageColor3 = Color3.new(0,0,0),
			ZIndex = 0,
		}, {
			Ratio  = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 10,
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0,4),
				PaddingRight = UDim.new(0,4),
				PaddingTop = UDim.new(0,4),
				PaddingBottom = UDim.new(0,4),
			}),
			Contents = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1,0,1,0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://3677918992",
				ScaleType = "Slice",
				SliceCenter = Rect.new(512,512,512,512),
				ImageColor3 = Color3.fromRGB(122,235,217),
				ZIndex = 0,
			}, childFrames),
			LivesDisplayFrame = LivesFrame(self.state.lives),
		})
	end
end

return Stats
