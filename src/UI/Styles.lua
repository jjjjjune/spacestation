--[[
	Contains reuseable styles to keep the look of the UI consistent.
]]

local rgb = Color3.fromRGB

local styles = {
	textSize = 16, -- px
	padding = 16, -- px

	fonts = {
		header = Enum.Font.GothamBlack,
		button = Enum.Font.GothamBold,
		text = Enum.Font.Gotham
	},

	colors = {
		background = rgb(255, 255, 255),
		text = rgb(30, 30, 30),
		placeholderText = rgb(136, 138, 136),
	}
}

return styles