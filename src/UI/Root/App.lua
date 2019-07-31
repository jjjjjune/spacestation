local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"
local Store = import "Shared/State/Store"
local Stats = import"UI/Components/Stats/Stats"
local DrawerButton = import "UI/Components/DrawerButton/DrawerButton"
local ShopDisplay = import "UI/Components/ShopDisplay/ShopDisplay"
local Cash = import "UI/Components/Cash/Cash"
local YesNoDialogue = import "UI/Components/YesNoDialogue/YesNoDialogue"
local Notifications = import "UI/Components/Notifications/Notifications"
local Icons = import "UI/Components/Icons/Icons"
local ClickDetectorIcons = import "UI/Components/ClickDetectorIcons/ClickDetectorIcons"
local AnimalControlIcons = import "UI/Components/AnimalControlIcons/AnimalControlIcons"
local Paycheck = import "UI/Components/Paycheck/Paycheck"

local function App()
	return Roact.createElement(RoactRodux.StoreProvider, { store = Store }, {
		Roact.createElement("ScreenGui", {ResetOnSpawn = false}, {
			Stats = Roact.createElement(Stats, {}),
			DrawerButton = Roact.createElement(DrawerButton, {}),
			Cash = Roact.createElement(Cash, {}),
			YesNoDialogue = Roact.createElement(YesNoDialogue, {}),
			ShopDisplay = Roact.createElement(ShopDisplay, {}),
			Notifications = Roact.createElement(Notifications, {}),
			Icons = Roact.createElement(Icons, {}),
			ClickDetectorIcons = Roact.createElement(ClickDetectorIcons, {}),
			AnimalControlIcons = Roact.createElement(AnimalControlIcons, {}),
			Paycheck = Roact.createElement(Paycheck, {}),
		})
	})
end

return App
