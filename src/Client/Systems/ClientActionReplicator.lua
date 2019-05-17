--[[
	Responds to the server telling this client to dispatch an action.

	See the 'Replication' module for how to replicate an action to the client.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local Store = import "Shared/State/Store"
local Replication = import "Shared/State/Replication"

local ClientActionReplicator = {}

function ClientActionReplicator:start()
	Messages:hook(Replication.MESSAGE_NAME, function(action)
		-- We trust that whatever action the server sent is valid.
		Store:dispatch(action)
	end)
	Messages:sendServer("ReplicationReady")
end

return ClientActionReplicator
