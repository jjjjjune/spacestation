local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

return {
	{
		icon = "rbxassetid://3678544294",
		hotkey = "SHIFT",
		pressed = function()
			Messages:send("ToggleSprint")
		end,
		name = "Sprint"
	},
	{
		icon = "rbxassetid://3678568074",
		hotkey = "G",
		name = "Gravity",
		pressed = function()
			Messages:send("ToggleGravity")
		end,
	},
	{
		icon = "rbxassetid://3678630131",
		hotkey = "X",
		name = "Helmet",
		pressed = function()
			Messages:sendServer("ToggleHelmet")
		end,
	},
}
