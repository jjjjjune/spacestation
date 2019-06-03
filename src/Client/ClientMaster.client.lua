local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {
	"../Systems/ClientInitStuff",
	"../Systems/ClientActionReplicator",
	"../Systems/ClientAnimations",
	"../Systems/MatthewCommands",
	"Shared/Systems/Chat",
	"../Systems/UI",
	"../Systems/UsingThings",
	"../Systems/Combat",
	"Shared/Systems/Sounds",
	"../Systems/TooltipSetter",
	"../Systems/UserStatusEffects",
	"../Systems/OceanEffects",
	"../Systems/SacrificeProgress",
	"../Systems/Building",
	"../Systems/Boats",
	"../Systems/Idols",
	"../Systems/Lighting",
	"../Systems/Animals",
	"../Systems/ClientProjectiles",
	"../Systems/FallDamage",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
