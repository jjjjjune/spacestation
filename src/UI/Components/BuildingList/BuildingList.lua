local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })

local StyleConstants = import "Shared/Data/StyleConstants"
local WorldConstants = import "Shared/Data/WorldConstants"
local Messages = import "Shared/Utils/Messages"
local BlueprintTypes = import "Shared/Data/BlueprintTypes"

local BuildingList = Roact.PureComponent:extend("BuildingList")

local selectedBlueprint

function BuildingList:init()
	self.visible = false
	Messages:hook("SetBlueprint", function(blueprint)
		selectedBlueprint = blueprint
		self:setState({})
	end)
end

local function getBuildingElements()
	if not selectedBlueprint then
		return {}
	end
	local elements ={}

	elements.List = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0,4),
		HorizontalAlignment = "Center",
	})

	local buildingsTable = BlueprintTypes[selectedBlueprint]
	for _, buildingName in pairs(buildingsTable) do
		table.insert(elements, Roact.createElement("TextButton", {
			Size = UDim2.new(.8,0,0,26),
			BorderSizePixel = 0,
			BackgroundColor3 = StyleConstants.WINDOW_BG,
			TextColor3 = StyleConstants.TEXT,
			Font = StyleConstants.FONT,
			Text = buildingName,
			TextScaled = true,
			[Roact.Event.Activated] = function()
				Messages:send("SetBuildingPlacing", buildingName)
			end,
		}))
	end

	return elements
end

function BuildingList:render()
	return
	Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(.5,0),
		Size = UDim2.new(.125,0,.2,0),
		Position = UDim2.new(.50,0,0.1,0),
		BackgroundTransparency = .8,
		Visible = (selectedBlueprint and true) or false,
		BackgroundColor3 = StyleConstants.WINDOW_BG,
	}, {
		ListFrame = Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency =1,
			ClipsDescendants = true,
			BorderSizePixel = 0,
		}, getBuildingElements()),
		CloseButton = Roact.createElement("TextButton", {
			AnchorPoint = Vector2.new(.5,0),
			Size = UDim2.new(.5, 0,.1,0),
			Position = UDim2.new(0.5,0,1.1,0),
			TextScaled = true,
			Font = StyleConstants.FONT_BOLD,
			Text = "Close",
			BorderSizePixel = 0,
			BackgroundColor3 = StyleConstants.HEALTH_COLOR,
			TextColor3 = StyleConstants.TEXT,
			[Roact.Event.Activated] = function()
				Messages:send("SetBuildingPlacing", nil)
				selectedBlueprint = nil
				self:setState({})
			end,
		})
	})

end

function BuildingList:didUpdate()

end

local function mapStateToProps(state, props)
	return {
	}
end

return Connect(mapStateToProps)(BuildingList)

