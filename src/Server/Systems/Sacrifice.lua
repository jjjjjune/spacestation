local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SacrificePoints = import "Shared/Data/SacrificePoints"
local PlayerData = import "Shared/PlayerData"

local CollectionService = game:GetService("CollectionService")

local function onSuccesfulSacrifice(godName, lava, item)
	item:Destroy()
end

local function onFailedSacrifice(godName, lava, item)
	item.Base.Velocity = Vector3.new(300, 700,0)
end

local function onSacrifice(lava, item)
	Messages:send("PlaySound", "Sacrifice", lava.Position)
end

local function onSacrificeLavaTouched(godName, hit, lava)
	local item = hit.Parent
	if CollectionService:HasTag(item, "Item") then
		local dropTag = item:FindFirstChild("DroppedBy")
		if dropTag then
			local player = game.Players:FindFirstChild(dropTag.Value)
			if player then
				local sacrificeValue = SacrificePoints[godName][item.Name] or 0
				local sacrifices = PlayerData:get(player, "sacrifices")
				if not sacrifices[godName] then
					sacrifices[godName] = sacrificeValue
				else
					sacrifices[godName] = sacrifices[godName] + sacrificeValue
				end
				PlayerData:set(player, "sacrifices", sacrifices)
				if not PlayerData:get(player, "sacrificeTotal"..godName) then
					PlayerData:set(player, "sacrificeTotal"..godName,1)
				else
					PlayerData:add(player, "sacrificeTotal"..godName,1)
				end
				if sacrificeValue > 0 then
					onSuccesfulSacrifice(godName, lava, item)
				else
					onFailedSacrifice(godName, lava, item)
				end
			end
		end
		onSacrifice(lava, item)
	end
	if item and item:FindFirstChild("Humanoid") then
		item.Humanoid.Health = 0
	end
end

local Sacrifice = {}

function Sacrifice:start()
	for _, lava in pairs(CollectionService:GetTagged("SacrificeLava")) do
		local godName = lava.Name
		lava.Touched:connect(function(hit)
			onSacrificeLavaTouched(godName, hit, lava)
		end)
	end
end

return Sacrifice
