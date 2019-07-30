local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

return {
	{
		icon = "rbxassetid://3536828297",
		hotkey = "SHIFT",
		pressed = function()
			Messages:send("ToggleSprint")
		end,
		name = "Sprint"
	},
	{
		icon = "rbxassetid://3536828221",
		hotkey = "G",
		name = "Gravity",
		pressed = function()
			Messages:send("ToggleGravity")
		end,
	},
	{
		icon = "rbxassetid://3559802858",
		hotkey = "X",
		name = "Helmet",
		pressed = function()
			Messages:sendServer("ToggleHelmet")
		end,
	},
}
