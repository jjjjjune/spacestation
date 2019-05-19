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
	return Roact.createElement("ScrollingFrame", {
		AnchorPoint = Vector2.new(.5,0),
		Size = UDim2.new(.125,0,.2,0),
		Position = UDim2.new(.50,0,0.1,0),
		BackgroundTransparency =1,
		Visible = (selectedBlueprint and true) or false,
		ClipsDescendants = true,
		BorderSizePixel = 0,
	}, getBuildingElements())
end

function BuildingList:didUpdate()

end

local function mapStateToProps(state, props)
	return {
	}
end

return Connect(mapStateToProps)(BuildingList)

