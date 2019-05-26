local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local function setup(animal)
	animal.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
end

local Animals = {}

function Animals:start()
	Messages:hook("SetupAnimalClient", function(animal)
		setup(animal)
	end)
	for _, animal in pairs(CollectionService:GetTagged("Animal")) do
		setup(animal)
	end
end

return Animals
