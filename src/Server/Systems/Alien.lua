local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local PlayerData = import "Shared/PlayerData"

local alienNeeded = true

local ALIEN_TIME = 180 + math.random(-20,100)

local Alien = {}

function Alien:start()
	Messages:hook("ConsumePlayerPart", function(player, part)
		print("yesss")
		local character = part.Parent
		local victimPlayer = game.Players:GetPlayerFromCharacter(character)
		if victimPlayer then
			PlayerData:add(player, "cash", 3)
			Messages:sendClient(player, "Notify", "+ $3")
			Messages:send("PlaySound", "Eating", part.Position)
			part:Destroy()
			if not character:FindFirstChild("LeftUpperLeg") and not character:FindFirstChild("RightUpperLeg") then
				character.Humanoid.HipHeight = .5
			end
		end
	end)
	Players.PlayerAdded:connect(function(player)
		player.CharacterAdded:connect(function(character)
			if alienNeeded then
			   -- if math.random(1, 5) == 1 then
					Messages:sendClient(player, "AddHunger", 10)
					CollectionService:AddTag(character, "Alien")
					Messages:sendClient(player, "Notify", "You are an alien! Try to consume players without being spotted.")
					Messages:send("GiveTool", player, "Consume")
				--end
				alienNeeded = false
            end
        end)
	end)
	spawn(function()
		while wait(ALIEN_TIME) do
			alienNeeded = true
		end
	end)
end

return Alien
