local import = require(game.ReplicatedStorage.Shared.Import)

local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")

local replicationReady = {}

local SignalObject = {}
function SignalObject.new(signals, action, callback)
    local SignalObject =  {
        callback = callback,
        ID = httpService:GenerateGUID(),
    }

   function SignalObject:unhook()
        signals:unhook(action, self.ID)
    end

    return SignalObject
end

local Messages = {}

if not game.ReplicatedStorage:FindFirstChild("SIGNAL_REMOTE") then
    local SIGNAL_REMOTE = Instance.new("RemoteEvent", game.ReplicatedStorage)
    SIGNAL_REMOTE.Name = "SIGNAL_REMOTE"
end

local SIGNAL_REMOTE = game.ReplicatedStorage:FindFirstChild("SIGNAL_REMOTE")

local isClient = runService:IsClient()
local isServer = runService:IsServer()

Messages.hooks = {}

function Messages:unhook(action, ID)
    for _, storedSignalObject in pairs(self.hooks[action]) do
        if storedSignalObject.ID == self.ID then
            self.hooks[action] = nil
        end
    end
end

function Messages:hook(action, callback)
    local hooks = self.hooks
    if not hooks[action] then
        hooks[action] = {}
    end
    local signalObject = SignalObject.new(self, action, callback)
    table.insert(hooks[action], signalObject)
    return signalObject
end

function Messages:send(action, ...)
	local actionHooksTable = self.hooks[action]

	if actionHooksTable then
		for _, hookFunction in pairs(actionHooksTable) do
			hookFunction.callback(...)
		end
		--warn("No defined hook for message: "..action)
	end
end

function Messages:sendServer(action, ...)
    SIGNAL_REMOTE:FireServer(action, ...)
end

function Messages:sendClient(player, action, ...)
	if not replicationReady[player] then
		repeat wait() until replicationReady[player] or (player.Parent == nil)
		if player.Parent == nil then
			return
		end
	end
	SIGNAL_REMOTE:FireClient(player, action, ...)
end

function Messages:reproOnClients(player, action, ...)
	for _, p in pairs(game.Players:GetPlayers()) do
		if p ~= player then
			if not replicationReady[p] then
				repeat wait() until replicationReady[p]
			end
			SIGNAL_REMOTE:FireClient(p, action, ...)
		end
	end
end

function Messages:sendAllClients(action, ...)
	for _, p in pairs(game.Players:GetPlayers()) do
		if not replicationReady[p] then
			repeat wait() until replicationReady[p]
		end
		SIGNAL_REMOTE:FireClient(p, action, ...)
	end
end

function Messages:init()
	Messages:hook("ReplicationReady", function(player)
		replicationReady[player] = true
	end)
    if isClient then
        SIGNAL_REMOTE.OnClientEvent:connect(function(action, ...)

            Messages:send(action, ...)
        end)
    end
    if isServer then
        SIGNAL_REMOTE.OnServerEvent:connect(function(player, action, ...)

            self:send(action, player, ...)
        end)
    end
end

Messages:init()

return Messages
