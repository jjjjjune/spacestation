local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local Recipes = import "Shared/Data/Recipes"
local ObjectReactions = import "Shared/Data/ObjectReactions"
local AddCash = import "Shared/Utils/AddCash"
local PlayerData = import "Shared/PlayerData"

local COOK_TIME = 5
local lastForceStep = time()

local function isWithin(pos, box)
	local headPos = pos
	local boxPos = box.Position
	local boxCorner1 = boxPos - Vector3.new(box.Size.X/2,box.Size.Y/2,box.Size.Z/2)
	local boxCorner2 = boxPos + Vector3.new(box.Size.X/2,box.Size.Y/2,box.Size.Z/2)
	local x1, y1, z1, x2, y2, z2 = boxCorner1.X, boxCorner1.Z,boxCorner1.Y,boxCorner2.X, boxCorner2.Z,boxCorner2.Y
	if headPos.X > x1 and headPos.X < x2 then
		if headPos.Z > y1 and headPos.Z < y2 then
			if headPos.Y > z1 and headPos.Y < z2 then
				return true
			end
		end
	end
	return false
end

local function burn(item)
	if not CollectionService:HasTag(item, "Burned") then
		Messages:send("PlaySound", "Smoke", item.Base.Position)
		Messages:send("PlayParticle", "Smoke", 15, item.Base.Position)
		for _, p in pairs(item:GetChildren()) do
			if p:IsA("BasePart") then
				p.BrickColor = BrickColor.new("Black")
			end
		end
	end
	CollectionService:AddTag(item, "Burned")
end

local function onCookedItem(transformItem)
	if transformItem:FindFirstChild("Hunger") then
		for _, p in pairs(game.Players:GetChildren()) do
			if p.Team.Name == "Cooks" then
				AddCash(p, math.ceil(transformItem.Hunger.Value/3))
			end
		end
	end
end

local function calculateReaction(item, owner)
	if CollectionService:HasTag(item, "Food") or Recipes[item.Name] then
		if not CollectionService:HasTag(item, "Cooked") and Recipes[item.Name] then
			if owner then
				PlayerData:add(owner, string.lower(item.Name).."Cooked",1)
				PlayerData:add(owner, string.lower(item.Name).."foodCooked",1)
			else
				if item:FindFirstChild("LastCarry") then
					PlayerData:add(item.LastCarry.Value, string.lower(item.Name).."Cooked",1)
					PlayerData:add(item.LastCarry.Value, string.lower(item.Name).."foodCooked",1)
				end
			end
			CollectionService:AddTag(item, "Cooked")
			Messages:send("PlaySound", "Burn", item.Base.Position)
			Messages:send("PlayParticle", "Smoke", 15, item.Base.Position)
			local transformItem = Recipes[item.Name]
			transformItem = game.ReplicatedStorage.Assets.Objects[transformItem]:Clone()
			transformItem.PrimaryPart = transformItem.Base
			transformItem:SetPrimaryPartCFrame(item.Base.CFrame)
			transformItem.Parent = workspace
			onCookedItem(transformItem)
			item:Destroy()
			return
		else
			burn(item)
		end
	end
	if CollectionService:HasTag(item, "Burned") then
		item:Destroy()
		return
	end
	if ObjectReactions[item.Name] then
		if not CollectionService:HasTag(item, "Cooked") then
			CollectionService:AddTag(item, "Cooked")
			-- uh oh
			Messages:send("PlaySound", "Burn", item.Base.Position)
			Messages:send("PlayParticle", "Smoke", 15, item.Base.Position)
			for _, v in pairs(item:GetChildren()) do
				if v:IsA("BasePart") then
					v.BrickColor = BrickColor.new("Bright orange")
					v.Material = Enum.Material.Neon
				end
			end
			return
		end
		local reaction = ObjectReactions[item.Name]
		if reaction.HEAT == "EXPLODE" then
			if owner then
				PlayerData:add(owner, string.lower(item.Name).."Exploded",1)
				PlayerData:add(owner, string.lower(item.Name).."objectsExploded",1)
			else
				if item:FindFirstChild("LastCarry") then
					PlayerData:add(item.LastCarry.Value, string.lower(item.Name).."Exploded",1)
					PlayerData:add(item.LastCarry.Value, string.lower(item.Name).."objectsExploded",1)
				end
			end
			Messages:send("CreateExplosion", item.Base.Position, 12)
			item:Destroy()
		end
	end
	if CollectionService:HasTag(item, "Supply") then
		for i = 1, item.Quantity.Value do
			Messages:send("OrderSupply", item)
		end
	end
end

local function doRadiusStepOnly()
	for _, heatArea in pairs(CollectionService:GetTagged("HeatArea")) do
		if heatArea.Temperature.Value > 300 then
			for _, item in pairs(CollectionService:GetTagged("Carryable")) do
				if item.Parent == workspace then
					if heatArea:FindFirstChild("Radius") then
						if (item.Base.Position - heatArea.Position).magnitude < heatArea.Radius.Value then
							calculateReaction(item)
						end
					end
				end
			end
			for _, animal in pairs(CollectionService:GetTagged("Animal")) do
				if animal.Parent == workspace then
					if heatArea:FindFirstChild("Radius") then
						if (animal.PrimaryPart.Position - heatArea.Position).magnitude < heatArea.Radius.Value then
							Messages:send("Burn", animal)
						end
					end
				end
			end
		end
	end
end

local function cookStep()
	for _, heatArea in pairs(CollectionService:GetTagged("HeatArea")) do
		if heatArea.Temperature.Value > 300 then
			for _, item in pairs(CollectionService:GetTagged("Carryable")) do
				if item.Parent == workspace then
					if isWithin(item.Base.Position, heatArea) then
						calculateReaction(item)
					else
						if heatArea:FindFirstChild("Radius") then
							if (item.Base.Position - heatArea.Position).magnitude < heatArea.Radius.Value then
								calculateReaction(item)
							end
						end
					end
				end
			end
			for _, animal in pairs(CollectionService:GetTagged("Animal")) do
				if animal.Parent == workspace and animal:FindFirstChild("PrimaryPart") then
					if isWithin(animal.PrimaryPart.Position, heatArea) then
						Messages:send("Burn", animal)
					end
				end
			end
			if heatArea.Anchored == true then
				for _, player in pairs(game.Players:GetPlayers()) do
					if player.Character then
						local animal = player.Character
						if animal.Parent == workspace then
							if animal.PrimaryPart and isWithin(animal.PrimaryPart.Position, heatArea) then
								Messages:send("Burn", animal)
							end
						end
					end
				end
			end
		end
	end
end

local function heatContactAt(position, radius, owner) -- for things like lasers
	for _, item in pairs(CollectionService:GetTagged("Carryable")) do
		if item.Parent == workspace then
			if (item.Base.Position - position).magnitude < radius then
				calculateReaction(item, owner)
			end
		end
	end
end

local lastStep = time()

local heatLoop = function()
	game:GetService("RunService").Stepped:connect(function()
		if time() - lastStep > COOK_TIME then
			cookStep()
			lastStep = time()
		end
	end)
end

local HeatAreas = {}

function HeatAreas:start()
	spawn(heatLoop)
	Messages:hook("ForceStep", function()
		if time() - lastForceStep > 1 then
			lastForceStep = time()
			doRadiusStepOnly()
		end
	end)
	Messages:hook("HeatContact", function(position, owner)
		heatContactAt(position, 5, owner)
	end)
	Messages:hook("ForceCalculateHeatReaction", function(item)
		calculateReaction(item)
	end)
end

return HeatAreas
