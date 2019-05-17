--[[

]]

local import = require(game.ReplicatedStorage.Shared.Import)

local t = import "t"
local Messages = import "Shared/Utils/Messages"
local Types  = import "Shared/Types"

local MESSAGE_NAME = "replicateAction"

local replication = {
	MESSAGE_NAME = MESSAGE_NAME
}

--[[
    Replicates an action to all players in the server.

    This is useful for very broad replication, such as if the server makes a
    change without input from a user. If a user was the cause of the dispatch,
    you'll typically want to use replicateExceptTo(). This way, the client can
	take care of dispatching locally for instant feedback, while the server
	works to catch everyone else up with the change.
]]
local replicateTypes = Types.IAction
function replication.replicate(action)
	assert(replicateTypes(action))

	Messages:sendAllClients(MESSAGE_NAME, action)

	return action
end

--[[
	Replicates an action to a specific player.
]]
local replicateToTypes = t.tuple(Types.Player, Types.IAction)
function replication.replicateTo(player, action)
	assert(replicateToTypes(player, action))

	Messages:sendClient(player, MESSAGE_NAME, action)

    return action
end

--[[
    Replicates an action to every player except the one given.

    This allows you to have the client perform an action locally, then have the
    server catch up other players.
]]
local replicateExceptToTypes = t.tuple(Types.Player, Types.IAction)
function replication.replicateExceptTo(excludedPlayer, action)
	assert(replicateExceptToTypes(excludedPlayer, action))

	Messages:reproOnClients(excludedPlayer, MESSAGE_NAME, action)

	return action
end

--[[
	Replicates an action from the client to the server.

	Due to the server needing to validate input, you have to pass in the action
	creator (not the result of calling the action), and the arguments to it.

	On the server, you must listen for the action being dispatched so it can be
	handled.

	Usage:

		-- shared

		-- You need touse  the `action()` function so that your actions have a
		-- `name` property. This is used for networking.
		local foo = action("FOO", function(arg)
			return return { arg = arg }
		end)

		-- client

		-- Notice that we do not pass in foo("bar") like we would with the other
		-- functions! We need the arguments to foo separate, so they can be sent
		-- to the server.
		store:dispatch(replicateToServer(foo, "bar"))

		-- server

		Messages(foo.name, function(bar)
			assert(typeof(bar) == "string")

			local action = foo(bar)
		end)
]]
local replicateToServerTypes = Types.IActionCreator
function replication.replicateToServer(actionCreator, ...)
	assert(replicateToServerTypes(actionCreator))

	Messages:sendServer(actionCreator.name, ...)

	return actionCreator(...)
end

return replication
