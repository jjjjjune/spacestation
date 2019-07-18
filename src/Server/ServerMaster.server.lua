local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {
	"Shared/Systems/Sounds",
	"Shared/PlayerData",
	"../Systems/Animations",
	"../Systems/Commands",
	"Shared/Systems/Chat",
	"../Systems/Particles",
	"../Systems/Oxygen",
	"../Systems/Appearance",
	"../Systems/Doors",
	"../Systems/MovementPreparation",
	"../Systems/Stats",
	"../Systems/LightSwitches",
	"../Systems/Tools",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
