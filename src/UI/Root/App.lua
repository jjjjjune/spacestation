--[[
	Entry-point to the game UI.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"
local HungerThirst = import "UI/Components/HungerThirst/HungerThirst"
local Inventory = import"UI/Components/Inventory/Inventory"
local Tooltip = import "UI/Components/Tooltip/Tooltip"
local DangerIndicator = import "UI/Components/DangerIndicator/DangerIndicator"
local BuildingList = import "UI/Components/BuildingList/BuildingList"
local IslandLOD = import "UI/Components/IslandLOD/IslandLOD"
local Store = import "Shared/State/Store"

local LayoutProvider = import "../LayoutProvider"
-- local LanguageProvider = import "../LanguageProvider"

local function App()
	return Roact.createElement(RoactRodux.StoreProvider, { store = Store }, {
		Roact.createElement("ScreenGui", {ResetOnSpawn = false}, {
			LayoutProvider = Roact.createElement(LayoutProvider),
			HungerThirst = Roact.createElement(HungerThirst),
			Tooltip = Roact.createElement(Tooltip, {
				tooltipName = Store:getState().tooltipInfo.tooltipName
			}),
			Inventory = Roact.createElement(Inventory, {
				isOpen = true,
				inventories = Store:getState().inventories
			}),
			DangerIndicator = Roact.createElement(DangerIndicator, {}),
			BuildingList = Roact.createElement(BuildingList, {}),
			IslandLOD = Roact.createElement(IslandLOD, {})
		})
	})
end

return App
