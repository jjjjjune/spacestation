local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"

return function(slotBegin, slotEnd, inventory, activatedCallback,refsTable, colors)
	local slots = {}
	for i = slotBegin, slotEnd do
		local myRef = refsTable[i..""]
		local info = inventory[i..""]
		local itemName = info or ""
		local col = colors[(i - slotBegin)+1]
		if not col then
			col = colors[1]
		end

		local rnd = Random.new(i)
		local rotation = rnd:NextNumber(-5,5)

		local slotComponent = Roact.createElement("ImageButton", {
			Size = UDim2.new(.2,0,.2,0),
			Image = "",
			LayoutOrder = i,
			[Roact.Ref] = myRef,
			[Roact.Event.MouseButton1Down] = function() activatedCallback(myRef,i.."") end,
			BorderSizePixel = 0,
			BackgroundColor3 = col,
			BackgroundTransparency = 1,
		}, {
			Constraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
			BG = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1,0,1,0),
				Image = "",
				BorderSizePixel = 0,
				BackgroundColor3 = col,
				--Rotation = rotation,
			}),
			ItemLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1,0,1,0),
				Text = itemName,
				TextScaled = true,
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 5,
				Font = "SourceSansBold",
				Active = false,
			}),
			ViewportFrame = Roact.createElement("ViewportFrame", {
				Size = UDim2.new(.9,0,.9,0),
				Position = UDim2.new(.05,0,.05,0),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 4,
				Visible = true,
			}),
			Shadow1 = Roact.createElement("ViewportFrame", {
				Size = UDim2.new(.9,0,.9,0),
				Position = UDim2.new(.05,-3,.05,0),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 3,
				Visible = true,
				ImageColor3 = Color3.new(0,0,0),
			}),
			Shadow2 = Roact.createElement("ViewportFrame", {
				Size = UDim2.new(.9,0,.9,0),
				Position = UDim2.new(.05,3,.05,0),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 3,
				Visible = true,
				ImageColor3 = Color3.new(0,0,0),
			}),
			Shadow3 = Roact.createElement("ViewportFrame", {
				Size = UDim2.new(.9,0,.9,0),
				Position = UDim2.new(.05,0,.05,3),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 3,
				Visible = true,

				ImageColor3 = Color3.new(0,0,0),
			}),
			Shadow4 = Roact.createElement("ViewportFrame", {
				Size = UDim2.new(.9,0,.9,0),
				Position = UDim2.new(.05,0,.05,-3),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 3,
				Visible = true,
				ImageColor3 = Color3.new(0,0,0),
			}),
			Shadow5= Roact.createElement("ViewportFrame", {
				Size = UDim2.new(.9,0,.9,0),
				Position = UDim2.new(.05,3,.05,-3),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 3,
				Visible = true,
				ImageColor3 = Color3.new(0,0,0),
			}),
			Shadow6 = Roact.createElement("ViewportFrame", {
				Size = UDim2.new(.9,0,.9,0),
				Position = UDim2.new(.05,3,.05,3),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 3,
				Visible = true,
				ImageColor3 = Color3.new(0,0,0),
			}),
			Shadow7 = Roact.createElement("ViewportFrame", {
				Size = UDim2.new(.9,0,.9,0),
				Position = UDim2.new(.05,-3,.05,3),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 3,
				Visible = true,

				ImageColor3 = Color3.new(0,0,0),
			}),
			Shadow8 = Roact.createElement("ViewportFrame", {
				Size = UDim2.new(.9,0,.9,0),
				Position = UDim2.new(.05,-3,.05,-3),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ZIndex = 3,
				Visible = true,
				ImageColor3 = Color3.new(0,0,0),
			}),
			--[[ImageLabel = Roact.createElement("ImageLabel", {
				Image = "rbxassetid://3150329645",
				BackgroundTransparency =1,
				Size = UDim2.new(1,0,1,0),
				ZIndex = 2,
			})--]]
		})
		slots[i] = slotComponent
	end

	return slots
end
