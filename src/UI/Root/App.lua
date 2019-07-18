--[[
	Entry-point to the game UI.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"
local Store = import "Shared/State/Store"
local Stats = import"UI/Components/Stats/Stats"

-- local LanguageProvider = import "../LanguageProvider"

--[[
	Inventory = Roact.createElement(Inventory, {
				isOpen = true,
				inventories = Store:getState().inventories
			}),
]]

local function App()
	return Roact.createElement(RoactRodux.StoreProvider, { store = Store }, {
		Roact.createElement("ScreenGui", {ResetOnSpawn = false}, {
			Stats = Roact.createElement(Stats, {})
		})
	})
end

return App
