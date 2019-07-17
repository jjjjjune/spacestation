local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {
	"../Systems/ClientInitStuff",
	"../Systems/ClientActionReplicator",
	"../Systems/ClientAnimations",
	"Shared/Systems/Chat",
	"../Systems/UI",
	"../Systems/Gravity",
	"../Systems/Stats",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
