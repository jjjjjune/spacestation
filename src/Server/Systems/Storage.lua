local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")

local STORAGE_TAG = "Storage"
local DESPAWN_TIME = 600
local ITEM_TAG = "Carryable"

local WorldItems = {}

local function isInStorage(item)
	if item.Parent ~= workspace then
		return true
	end
	for _, storageInstance in pairs(CollectionService:GetTagged(STORAGE_TAG)) do
		local origin = storageInstance.Base.Position
		local base = storageInstance.Base
		local range = base.Size.X
		local vec1 = (origin + Vector3.new(-range,-(range*2),-range))
		local vec2 = (origin + Vector3.new(range,(range*2),range))
		local region = Region3.new(vec1, vec2)
		local parts = workspace:FindPartsInRegion3(region,nil, 10000)
		for _, part in pairs(parts) do
			if part.Parent == item then
				return true
			end
		end
	end
	if item:FindFirstChild("Base") and item.Base.Anchored == false then
		for _, v in pairs(item.Base:GetConnectedParts()) do -- if an item is connected to something it wont despawn
			if v.Parent ~= item then
				return true
			end
		end
	end
	return false
end

local function anchor(model)
	for _, p in pairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			p.Anchored = true
		end
	end
end

local Storage = {}

function Storage:start()
	CollectionService:GetInstanceAddedSignal(ITEM_TAG):connect(function(item)
		if item.Parent == workspace then
			table.insert(WorldItems, {item = item, time = tick()})
		end
	end)
	for _, item in pairs(CollectionService:GetTagged(ITEM_TAG)) do
		if item.Parent == workspace then
			table.insert(WorldItems, {item = item, time = tick()})
		end
	end
	spawn(function()
		while wait(1) do
			for index, itemTable in pairs(WorldItems) do
				local model = itemTable.item
				if isInStorage(model) then
					itemTable.time = tick()
					if model.Parent == workspace then
						anchor(model)
					end
				end
				if tick() - itemTable.time > DESPAWN_TIME then
					itemTable.item:Destroy()
					table.remove(itemTable, index)
				end
			end
		end
	end)
end

return Storage
