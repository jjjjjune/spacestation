local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })
local StyleConstants = import "Shared/Data/StyleConstants"

local function HungerThirst(props)
	local tooltipName = props.tooltipInfo.tooltipName
	local tooltipDescription = props.tooltipInfo.tooltipDescription
	local position = props.tooltipInfo.tooltipPosition
	local key = props.tooltipInfo.tooltipButton

	return Roact.createElement("Frame", {
		Size = UDim2.new(0,180,0,50),
		Position = position or UDim2.new(0,0,0,0),
		Visible = props.tooltipInfo.tooltipVisible,
		BackgroundColor3 = StyleConstants.WINDOW_DARK,
		BorderSizePixel = 0,
		--BackgroundTransparency = 1
	}, {
		DescriptionFrame = Roact.createElement("Frame", {
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			--Visible = false
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0,4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),
			DescLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1,0,1,0),
				Text = tooltipDescription,
				TextXAlignment = "Left",
				TextYAlignment = "Top",
				TextColor3 = StyleConstants.TEXT,
				Font = StyleConstants.FONT,
				TextSize = 18,
				TextWrapped = true,
				BackgroundTransparency = 1
			})
		}),
		NameFrame = Roact.createElement("Frame", {
			Size = UDim2.new(1,0,0,24),
			Position = UDim2.new(0,0,0,-24),
			BackgroundColor3 = StyleConstants.HEALTH_COLOR,
			BorderSizePixel = 0,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0,6),
				PaddingRight = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
			}),
			NameLabel = Roact.createElement("TextLabel", {
				Size = UDim2.new(1,0,1,0),
				Text = (tooltipName or "no tooltip"):upper().."("..(key or "")..")",
				TextXAlignment = "Left",
				TextYAlignment = "Top",
				TextColor3 = StyleConstants.TEXT,
				Font = StyleConstants.FONT_BOLD,
				TextSize = 16,
				TextWrapped = true,
				BackgroundTransparency = 1
			})
		})
	})
end

local function mapStateToProps(state, props)
	return {
		tooltipInfo = state.tooltipInfo,
	}
end

return Connect(mapStateToProps)(HungerThirst)
