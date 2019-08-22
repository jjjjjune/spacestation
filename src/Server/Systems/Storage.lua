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
				return storageInstance
			end
		end
	end
	if item:FindFirstChild("Base") and item.Base.Anchored == false then
		for _, v in pairs(item.Base:GetConnectedParts()) do -- if an item is connected to something it wont despawn
			if v.Parent ~= item then
				return v.Parent
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

local function setCanCollide(model, canCollide)
	for _, p in pairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			p.CanCollide = canCollide
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
	Messages:hook("OnObjectReleased", function(player, object)
		local ignore = {object}--CollectionService:GetTagged("Carryable")
		for i, v in pairs(ignore) do
			if CollectionService:HasTag(v, "Mechanism") then
				table.remove(ignore, i)
			end
		end
		local r = Ray.new(object.Base.Position, Vector3.new(0,-8,0))
		local hit, pos = workspace:FindPartOnRayWithIgnoreList(r, ignore)
		if hit and ((CollectionService:HasTag(hit.Parent, "Vehicle") or CollectionService:HasTag(hit.Parent, "Carryable")) and hit.Anchored == false) then
			Messages:send("PlaySound", "Click", pos)
			--setCanCollide(object, false)
			local f = Vector3.new(0,1,0)
			local dist = (pos*f - object.Base.Position*f).magnitude
			--object:SetPrimaryPartCFrame(object.PrimaryPart.CFrame * CFrame.new(0, -dist, 0))
			object:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.new(0, object.Base.Size.Y/2,0))
			local vehicleWeld = Instance.new("WeldConstraint", object.Base)
			vehicleWeld.Name = "VehicleWeld"
			vehicleWeld.Parent= object.Base
			vehicleWeld.Part0 = object.Base
			vehicleWeld.Part1 = hit
		else
			setCanCollide(object, true)
		end
	end)
	spawn(function()
		while wait(1) do
			for index, itemTable in pairs(WorldItems) do
				local model = itemTable.item
				local storage =isInStorage(model)
				if storage then
					itemTable.time = tick()
					if model.Parent == workspace and storage.Base.Anchored == true and not (model.Base:FindFirstChild("VehicleWeld")) then
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
