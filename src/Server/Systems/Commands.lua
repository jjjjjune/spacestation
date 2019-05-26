local Commands = {}

local import = require(game.ReplicatedStorage.Shared.Import)

function Commands:start()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Cmdr = require(ReplicatedStorage.Lib.Cmdr)
	local commandsFolder = import "Server/Commands"
	local hooksFolder = import "Server/Hooks"
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(commandsFolder)
	Cmdr:RegisterHooksIn(hooksFolder)
end

return Commands
