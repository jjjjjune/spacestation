local import = require(game.ReplicatedStorage.Shared.Import)

local Replicate, ReplicateTo = import("Shared/State/Replication", { "replicate", "replicateTo" })
local Messages = import "Shared/Utils/Messages"
local SetInventory = import "Shared/Actions/Inventories/SetInventory"
local SetItemPosition = import "Shared/Actions/Inventories/SetItemPosition"
local Store = import "Shared/State/Store"
local PlayerData = import "Shared/PlayerData"
local IdolsList = import "Shared/Data/Idols"
local ProjectileFunctions = import "Shared/Data/ProjectileFunctions"
local HttpService = game:GetService("HttpService")
local GetInventorySize = import "Shared/Utils/GetInventorySize"

local playerTargetPositions ={}

local PlayerInventories = {}

local function getInventory(player)
	local state = Store:getState()
	local inventory = state.inventories[tostring(player.UserId)]
	return inventory
end

local function saveInventory(player) -- gonna have to use this to save them manually for now
	local inventory = getInventory(player)
	PlayerData:set(player, "inventory", inventory)
	Messages:send("OnInventoryUpdated", player)
end

local function canPickupItem(player,item)
	local inventorySize = GetInventorySize(player)
	local occupiedSlots = 0
	local savedInventory = getInventory(player)
	for i = 1, inventorySize do
		if savedInventory[i..""] ~= nil then
			occupiedSlots = occupiedSlots + 1
		end
	end
	if occupiedSlots >= inventorySize then
		return false
	end
	return true
end

local function pickupItem(player, item)
	if not item.Parent == workspace then
		return
	end
	item.Parent = game.ServerStorage
	local inventory = getInventory(player)
	local inventorySize = GetInventorySize(player)
	local chosenSlot = "100000"
	for i = 1, inventorySize do
		if not inventory[i..""] then
			chosenSlot = i..""
			break
		end
	end
	Store:dispatch(ReplicateTo(player, SetItemPosition(tostring(player.UserId),item.Name,chosenSlot)))
	saveInventory(player)
	item:Destroy()
end

local function isAlive(player)
	return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and not player.Character:FindFirstChildOfClass("ForceField", true)
end

local function throwItem(player, item, targetPos)
	Messages:sendClient(player, "Throw")
	spawn(function()
		wait(.5)
		Messages:send("PlaySound", "DeepWhip", player.Character.Head.Position)
		local id = HttpService:GenerateGUID()
		Messages:send("CreateProjectile", id, player.Character.Head.Position, playerTargetPositions[player] or targetPos,
		game.ReplicatedStorage.Assets.Items[item]:Clone(),
		player.Character, player)
	end)
end

function PlayerInventories:start()
	Messages:hook("SetItemPosition", function(player, userId, item,position)
		Store:dispatch(SetItemPosition(userId,item,position))
	end)
	Messages:hook("GrabItem", function(player, item)
		if isAlive(player) then
			if (item.Base.Position - player.Character.HumanoidRootPart.Position).magnitude < 20 and item.Parent == workspace then
				if canPickupItem(player,item) then
					pickupItem(player,item)
				end
			end
		end
	end)
	Messages:hook("DropItem", function(player, slot, targetPos)
		local inventory = getInventory(player)
		local item = inventory[slot]
		local userId = tostring(player.UserId)
		local start = player.Character.Head.Position
		local length = math.min(30, (start - targetPos).magnitude)
		local r = Ray.new(start, (targetPos-start).unit*length)
		local hit, targetPos = workspace:FindPartOnRay(r, workspace)
		if item then
			if ProjectileFunctions[item] then
				throwItem(player, item, targetPos)
			else
				local droppedTag = Instance.new("StringValue")
				droppedTag.Name = "DroppedBy"
				droppedTag.Value = player.Name
				Messages:send("MakeItem", item, targetPos, droppedTag, player)
			end
			Store:dispatch(ReplicateTo(player, SetItemPosition(userId,nil,slot)))
			saveInventory(player)
		end
	end)

	game.Players.PlayerAdded:connect(function(player)
		local savedInventory = PlayerData:get(player, "inventory")
		local myId = tostring(player.UserId)
		Store:dispatch(ReplicateTo(player,SetInventory(myId, savedInventory)))
		spawn(function()
			wait()
			Store:dispatch(ReplicateTo(player, SetInventory(myId, savedInventory)))
		end)
		Messages:send("OnInventoryUpdated", player)
	end)
	Messages:hook("UpdatePlayerTargetPosition", function(player, position)
		playerTargetPositions[player] = position
	end)
	Messages:hook("FirstRespawn", function(player)
		local idol = PlayerData:get(player, "idol")
		local userId = tostring(player.UserId)
		if idol and idol ~= "" then
			local itemName = IdolsList[idol].startItem
			local slot = "1"
			Store:dispatch(ReplicateTo(player, SetItemPosition(userId,itemName,slot)))
		end
		Store:dispatch(ReplicateTo(player, SetItemPosition(userId,"Blueprint","2")))
		saveInventory(player)
	end)

	Messages:hook("PlayerDied", function(player)
		local state = Store:getState()
		local userId = tostring(player.UserId)
		local playerInventory = state.inventories[userId]
		for slot, item in pairs(playerInventory) do
			Store:dispatch(ReplicateTo(player, SetItemPosition(userId,nil,slot)))
			local pos = PlayerData:get(player, "position")
			pos = Vector3.new(pos.x, pos.y, pos.z)
			if player.Character and player.Character:FindFirstChild("Head") then
				pos = player.Character.Head.Position
			end
			if math.random(1,3) == 1 then
				Messages:send("MakeItem", item, pos + Vector3.new(math.random(-10,10), 4, math.random(-10,10)))
			end
			if math.random(1,6) == 1 then
				Messages:send("MakeItem", "Bone", pos + Vector3.new(math.random(-10,10), 4, math.random(-10,10)))
			end
		end
		saveInventory(player)
	end)

	Messages:hook("SwapItems", function(player, slot1, slot2)
		local state = Store:getState()
		local userId = tostring(player.UserId)
		local playerInventory = state.inventories[userId]
		local originalItem1 = playerInventory[slot1]
		local originalItem2 = playerInventory[slot2]
		Store:dispatch(ReplicateTo(player, SetItemPosition(userId,originalItem2,slot1)))
		Store:dispatch(ReplicateTo(player, SetItemPosition(userId,originalItem1,slot2)))
		saveInventory(player)
	end)

end

return PlayerInventories
