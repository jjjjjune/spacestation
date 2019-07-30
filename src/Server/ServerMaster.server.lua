local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {
	"Shared/Systems/Sounds",
	"Shared/PlayerData",
	"../Systems/Animations",
	"../Systems/Commands",
	"Shared/Systems/Chat",
	"Shared/Systems/Ragdoll",
	"../Systems/ClickDetectors",
	"../Systems/Particles",
	"../Systems/Oxygen",
	"../Systems/Appearance",
	"../Systems/Doors",
	"../Systems/MovementPreparation",
	"../Systems/Stats",
	"../Systems/LightSwitches",
	"../Systems/Tools",
	"../Systems/Drawers",
	"../Systems/Teams",
	"../Systems/Damage",
	"../Systems/Projectiles",
	"../Systems/Knockback",
	"../Systems/Machines",
	"../Systems/Carrying",
	"../Systems/Alien",
	"../Systems/Animals",
	"../Systems/Crates",
	"../Systems/HeatAreas",
	"../Systems/Explosions",
	"../Systems/CargoOrdering",
	"../Systems/Ships",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
