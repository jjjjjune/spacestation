local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local Boats = {}

function Boats:start()
	CollectionService:GetInstanceAddedSignal("Building"):connect(function(boat)
		if CollectionService:HasTag(boat, "Boat") then
			local seat = boat.VehicleSeat
			local signal = seat:GetPropertyChangedSignal("Occupant")
			signal:connect(function()
				local occupant = seat.Occupant
				if occupant then
					local character = occupant.Parent
					local player = game.Players:GetPlayerFromCharacter(character)
					if player then
						seat:SetNetworkOwner(player)
					end
				end
			end)
		end
	end)
end

return Boats
