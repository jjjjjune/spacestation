local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local loadOrder = {
	"../Systems/ClientInitStuff",
	"../Systems/ClientActionReplicator",
	"../Systems/ClientAnimations",
	"Shared/Systems/Chat",
	"Shared/Systems/Sounds",
	"Shared/Systems/Ragdoll",
	"../Systems/UI",
	"../Systems/Controller",
	"../Systems/Stats",
	"../Systems/Drawers",
	"../Systems/TeamSwitch",
	"../Systems/Shops",
	"../Systems/Tools",
	"../Systems/ClientProjectiles",
	"../Systems/DamageEffect",
	"../Systems/Knockback",
	"../Systems/Carrying",
	"../Systems/ClickDetectors",
	"../Systems/HeatAreas",
	"../Systems/Vehicles",
}

local lastStart = time()
for _, path in ipairs(loadOrder) do
	local system = import(path)
	lastStart = time()
	system:start()
	if time() - lastStart > .1 then
		warn(path, " IS YIELDING, WTF????")
	end
end
