local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local t = import "t"
local Padding = import "UI/Components/Padding"
local Styles = import "UI/Styles"

local IProps = t.interface({
	name = t.string,
	layoutOrder = t.integer,
})

local function PlayerLabel(props)
	assert(IProps(props))

	return Roact.createElement("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		LayoutOrder = props.layoutOrder,
		BackgroundColor3 = Styles.colors.background,
		BorderSizePixel = 0,
		Text = props.name,
		TextSize = Styles.textSize,
		Font = Styles.fonts.text,
		TextColor3 = Styles.colors.text,
		TextXAlignment = Enum.TextXAlignment.Left
	}, {
		Padding = Roact.createElement(Padding, {
			size = Styles.padding/4
		})
	})
end

return PlayerLabel
