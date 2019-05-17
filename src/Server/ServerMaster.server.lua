local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {
	"Shared/Systems/Sounds",
	"Shared/PlayerData",
	"../Systems/Animations",
	"../Systems/Commands",
	"Shared/Systems/Chat",
	"../Systems/Users",
	"../Systems/Stats",
	"../Systems/PlayerInventories",
	"../Systems/Death",
	"../Systems/Items",
	"../Systems/Equipment",
	"../Systems/Combat",
	"../Systems/Particles",
	"../Systems/World",
	"../Systems/Resources",
	"../Systems/ResourceCollection",
	"../Systems/Crafting",
	"../Systems/FallDamage",
	"../Systems/Sacrifice",
	"../Systems/Buildings",
	"../Systems/Boats",
	"../Systems/Hell",
	"../Systems/Idols",
	"../Systems/Animals"
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
