local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local Food = import "Shared/Data/Food"
local ObjectReactions = import "Shared/Data/ObjectReactions"

local COOK_TIME = 5

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

local function calculateReaction(item)
	if CollectionService:HasTag(item, "Food") then
		if not CollectionService:HasTag(item, "Cooked") then
			CollectionService:AddTag(item, "Cooked")
			Messages:send("PlaySound", "Burn", item.Base.Position)
			Messages:send("PlayParticle", "Smoke", 15, item.Base.Position)
			local transformItem = Food[item.Name]
			transformItem = game.ReplicatedStorage.Assets.Objects[transformItem]:Clone()
			transformItem.PrimaryPart = transformItem.Base
			transformItem:SetPrimaryPartCFrame(item.Base.CFrame)
			transformItem.Parent = workspace
			item:Destroy()
			return
		else
			if Food[item.Name] then
				burn(item)
			end
		end
	end
	if ObjectReactions[item.Name] then

	end
end

local function cookStep()
	for _, heatArea in pairs(CollectionService:GetTagged("HeatArea")) do
		for _, item in pairs(CollectionService:GetTagged("Carryable")) do
			if item.Parent == workspace then
				if isWithin(item.Base.Position, heatArea) then
					calculateReaction(item)
				end
			end
		end
	end
end

local heatLoop = function()
	while wait(COOK_TIME) do
		cookStep()
	end
end

local HeatAreas = {}

function HeatAreas:start()
	for _, heatArea in pairs(CollectionService:GetTagged("HeatArea")) do
		heatArea.Parent = game.ServerStorage
	end
	spawn(heatLoop)

end

return HeatAreas
