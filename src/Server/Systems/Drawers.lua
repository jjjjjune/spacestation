local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local LootData = import "Shared/Data/LootData"

local wasLootSpawned = {}

local LOOT_SPAWN_TIME = 60 -- new loot babey

local function searchDrawer(player, drawer)
	local tool = drawer.Tool.Value
	if tool ~= nil then
		if wasLootSpawned[drawer.Tool.Value] then
			tool.Parent = player.Backpack
			Messages:send("ConnectEvents", tool)
		else
			tool.Parent = player.Character
		end
		Messages:sendClient(player, "OnToolGiven", tool)
		drawer.Tool.Value = nil
	end
end

local function depositTool(player, drawer)
	local tool = player.Character:FindFirstChildOfClass("Tool")
	if tool.Name == "Consume" then
		return
	end
	tool.Parent = game.Lighting
	drawer.Tool.Value = tool
end

local function depositToolDirectly(drawer, tool)
	tool.Parent = game.Lighting
	drawer.Tool.Value = tool
end

local function spawnLoot()
	local lootableDrawers = {}
	for _, drawer in pairs(CollectionService:GetTagged("Drawer")) do
		if drawer:FindFirstChild("LootType") and drawer.Tool.Value == nil then
			table.insert(lootableDrawers, drawer)
		end
	end
	if #lootableDrawers > 0 then
		local drawer = lootableDrawers[math.random(1, #lootableDrawers)]
		local lootTable = LootData[drawer.LootType.Value]
		local tool = lootTable[math.random(1, #lootTable)]:Clone()
		wasLootSpawned[tool] = true
		depositToolDirectly(drawer, tool)
	end
end

local Drawers = {}

function Drawers:start()
	for _, drawer in pairs(CollectionService:GetTagged("Drawer")) do
		local tool = Instance.new("ObjectValue", drawer)
		tool.Name = "Tool"
	end
	Messages:hook("SearchDrawer", function(player, drawer)
		searchDrawer(player,drawer)
	end)
	Messages:hook("DepositTool", function(player, drawer)
		searchDrawer(player, drawer)
		depositTool(player, drawer)
	end)
	spawn(function()
		while wait(LOOT_SPAWN_TIME) do
			spawnLoot()
		end
	end)
end

return Drawers
