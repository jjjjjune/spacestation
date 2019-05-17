local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"

local ItemGrid = Roact.PureComponent:extend("ItemGrid")
local Connect = import("RoactRodux", { "connect" })

function ItemGrid:init(suppliedProps)
	self.frameSize = suppliedProps.frameSize
	self.framePosition = suppliedProps.framePosition
	self.refHolder = suppliedProps.refHolder
	self.startSlot = suppliedProps.startSlot
	self.endSlot = suppliedProps.endSlot
	self.verticalAlignment = suppliedProps.verticalAlignment
	self.fillDirection = suppliedProps.fillDirection
end

function ItemGrid:getGridElements()
	local gridItems = {}
	gridItems["layout"] = Roact.createElement("UIGridLayout", {
		VerticalAlignment = self.verticalAlignment or "Center",
		HorizontalAlignment = "Center",
		CellSize = UDim2.new(0,self.gridSizeX,0,self.gridSizeX),
		CellPadding = UDim2.new(0,4,0,4),
		FillDirection = self.fillDirection
	})
	gridItems["padding"] = Roact.createElement("UIPadding",{
		PaddingLeft = UDim.new(0,6),
		PaddingRight = UDim.new(0,6),
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
	})
	for i = self.startSlot,self.endSlot do

		if not self.refHolder[i] then
			self.refHolder[i] = Roact.createRef()
		end

		local info = self.props.inventory[i]
		local itemName = info or ""
		local col = Color3.new(1,1,1)

		if itemName == "" then
			col = Color3.new(.5,.5,.5)
		end

		gridItems[i] = Roact.createElement(Roact.createElement("ImageButton", {
			Size = UDim2.new(.2,0,.2,0),
			[Roact.Ref] = self.refHolder[i],
			Image = "",
		}, {
			Constraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			ItemLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1,0,1,0),
				Text = itemName,
				TextScaled = true,
				BackgroundColor3 = col,
			})
		}))
	end
	return gridItems
end

function ItemGrid:render(props)
	return Roact.createElement("Frame", {
		Size = self.frameSize,
		Position = self.framePosition,
	},self:getGridElements())
end

return Connect(nil,function(dispatch)
	return {}
end)
