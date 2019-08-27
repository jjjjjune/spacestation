local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Constants = import "Shared/Data/DataConstants"
local dataStoreService = game:GetService("DataStoreService")

local SAVE_TIME = 30

local data = {}
local dataReady = {}

--[[
    REMEMBER TO USE DATA:GET AND NOT DATA.GET
]]

local function getDefaultData()
    local data = {}
    for key, value in pairs(Constants.DEFAULT_DATA) do
        data[key] = value
    end
    return data
end

local function yieldUntilDataReady(player)
    if dataReady[player.UserId] then
        return
    end
    repeat wait() until dataReady[player.UserId] ~= nil
end

function data:onDataChanged(player)
	yieldUntilDataReady(player)
	Messages:send("PlayerDataUpdated", player, self.cache[player.UserId])
    Messages:sendClient(player, "PlayerDataSet", self.cache[player.UserId])
end

function data:get(player,key)
    yieldUntilDataReady(player)
    return self.cache[player.UserId][key]
end

function data:set(player, key, value)
	yieldUntilDataReady(player)
    self.cache[player.UserId][key] = value
    self:onDataChanged(player)
end

function data:add(player, key, value)
    yieldUntilDataReady(player)
	local data = self.cache[player.UserId]
	if not data[key] then
		data[key] = 0
	end
    data[key] = data[key] + value
    self:onDataChanged(player)
end

function data:loadIntoCache(player)
    local data = getDefaultData()
    local loadedData = self.dataStore:GetAsync(player.UserId)
    if loadedData then
        for key, value in pairs(loadedData) do
            data[key] = value
        end
    end
    self.cache[player.UserId] = data
    self:onDataChanged(player)
end

function data:save(player)
    local data = self.cache[player.UserId]
    if data then
        self.dataStore:SetAsync(player.UserId, data)
    end
end

function data:saveCache()
    for id, data in pairs(self.cache) do -- stagger these calls so they are less likely to throttle
        wait(1)
        spawn(function() self.dataStore:SetAsync(id, data) end)
    end
end

function data:clearFromCache(player)
    self.cache[player.UserId] = nil
end

local lastSave = time()

function data:start()
    self.cache = {}
    local dataStore = Constants.TEST_STORE
    if game.PlaceId == 3131676270 and not game:GetService("RunService"):IsStudio() then
        dataStore = Constants.PRODUCTION_STORE
    end

    self.dataStore = dataStoreService:GetDataStore(dataStore)

    if self.initialized then
        return
    else
        self.initialized = true
    end

    game.Players.PlayerAdded:connect(function(player)
        self:loadIntoCache(player)
    end)

	game.Players.PlayerRemoving:connect(function(player)
		Messages:send("PlayerIsRemoving",player)
	end)

	Messages:hook("PlayerIsRemoving", function(player)
		spawn(function()
			self:save(player)
			self:clearFromCache(player)
			dataReady[player.UserId] = nil
			Messages:send("PlayerHasRemoved",player)
		end)
	end)

	game:GetService("RunService").Stepped:connect(function()
		if time() - lastSave > SAVE_TIME then
			lastSave = time()
			spawn(function() self:saveCache() end) -- savecache is asynchronous
		else
			return
		end
	end)

    Messages:hook("DataReadySignal", function(player)
        dataReady[player.UserId] = true
	end)

	game:BindToClose(function() self:saveCache() end)
end

return data
