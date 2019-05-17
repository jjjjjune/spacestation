local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local t = import "t"
local Padding = import "UI/Components/Padding"
local Styles = import "UI/Styles"

local IProps = t.interface({
	placeholder = t.string,
	layoutOrder = t.integer,
	onSubmit = t.callback
})

local function InputField(props)
	assert(IProps(props))

	return Roact.createElement("TextBox", {
		PlaceholderText = props.placeholder,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		LayoutOrder = props.layoutOrder,
		BackgroundColor3 = Styles.colors.background,
		PlaceholderColor3 = Styles.colors.placeholderText,
		Text = "",
		TextSize = Styles.textSize,
		Font = Styles.fonts.text,
		TextXAlignment = Enum.TextXAlignment.Left,

		[Roact.Event.FocusLost] = function(rbx, enterPressed)
			if enterPressed then
				props.onSubmit(rbx.Text)
				rbx.Text = ""
			end
		end
	}, {
		Padding = Roact.createElement(Padding)
	})
end

return InputField
