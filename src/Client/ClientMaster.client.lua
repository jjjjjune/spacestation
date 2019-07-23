local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local loadOrder = {
	"../Systems/ClientInitStuff",
	"../Systems/ClientActionReplicator",
	"../Systems/ClientAnimations",
	"Shared/Systems/Chat",
	"Shared/Systems/Sounds",
	"../Systems/UI",
	"../Systems/Gravity",
	"../Systems/Stats",
	"../Systems/Drawers",
	"../Systems/TeamSwitch",
	"../Systems/Shops",
	"../Systems/Tools",
	"../Systems/ClientProjectiles",
	"../Systems/DamageEffect",
	"../Systems/Knockback"
}

local lastStart = time()
for _, path in ipairs(loadOrder) do
	local system = import(path)
	--print("starting: ", path)
	lastStart = time()
	system:start()
	--print(path, "took: ", time() - lastStart)
	if time() - lastStart > .1 then
		warn(path, " IS YIELDING, WTF????")
	end
end
