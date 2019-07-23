local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local DAMAGE = 5

local Damage = {}

function Damage:start()
	for _, damageBlock in pairs(CollectionService:GetTagged("Damage")) do
		damageBlock.Touched:connect(function(hit)
			if hit.Parent:FindFirstChild("Humanoid") then
				hit.Parent.Humanoid:TakeDamage(DAMAGE)
			end
		end)
	end
end

return Damage
