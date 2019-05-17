local Commands = {}

local import = require(game.ReplicatedStorage.Shared.Import)

function Commands:start()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Cmdr = require(ReplicatedStorage.Lib.Cmdr)
	local commandsFolder = import "Server/Commands"
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(commandsFolder)
end

return Commands
