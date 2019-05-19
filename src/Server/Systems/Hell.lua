local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local Hell = {}

function Hell:start()
	local hellExit = CollectionService:GetTagged("HellExit")[1]
	hellExit.Touched:connect(function(hit)
		local char = hit.Parent
		if char:FindFirstChild("Humanoid") then
			local player = game.Players:GetPlayerFromCharacter(char)
			Messages:send("PlayerReset", player )
			Messages:send("FirstRespawn", player)
		end
	end)
	local hellLava = CollectionService:GetTagged("HellLava")[1]
	hellLava.Touched:connect(function(hit)
		local char = hit.Parent
		if char:FindFirstChild("Humanoid") then
			char.Humanoid.Health = 0
		end
	end)
end

return Hell
