local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local PlayerData = import "Shared/PlayerData"
local IdolsList = import "Shared/Data/Idols"

local CollectionService = game:GetService("CollectionService")

local function prepareIdol(idol)
	local hitbox = Instance.new("Part")
	hitbox.Size = idol:GetModelSize()
	hitbox.CFrame = idol:GetModelCFrame()
	hitbox.Transparency= 1
	hitbox.Anchored = true
	hitbox.Parent = idol
	hitbox.Name = "Hitbox"
	local clickDetector = Instance.new("ClickDetector", hitbox)
	clickDetector.MouseClick:connect(function(player)
		local info = IdolsList[idol.Name]
		local stat = info.stat
		local needed = info.needed
		local myAmount = PlayerData:get(player, stat)
		if myAmount >= needed then
			print("yes!!!")
			PlayerData:set(player, "idol", idol.Name)
			Messages:send("OnMaskUpdated",player)
		end
	end)
end

local Idols = {}

function Idols:start()
	for _, idol in pairs(CollectionService:GetTagged("Idol")) do
		prepareIdol(idol)
	end
end

return Idols

