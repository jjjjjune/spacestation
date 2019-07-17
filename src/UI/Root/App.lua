--[[
	Entry-point to the game UI.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local RoactRodux = import "RoactRodux"
local Store = import "Shared/State/Store"

-- local LanguageProvider = import "../LanguageProvider"

local function App()
	return Roact.createElement(RoactRodux.StoreProvider, { store = Store }, {
		Roact.createElement("ScreenGui", {ResetOnSpawn = false}, {

		})
	})
end

return App
