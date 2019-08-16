local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local PlayerData = import "Shared/PlayerData"

local alienNeeded = true

local ALIEN_TIME = 180 + math.random(-20,100)

local lastAlienNeededSwitch = time()

local Alien = {}

function Alien:start()
	Messages:hook("ConsumePlayerPart", function(player, part)
		local character = part.Parent
		local victimPlayer = game.Players:GetPlayerFromCharacter(character)
		if victimPlayer and part.Name ~= "UpperTorso" and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" and part.Name ~= "LowerTorso" then
			PlayerData:add(player, "cash", 3)
			Messages:sendClient(player, "Notify", "+ $3")
			Messages:send("PlaySound", "Eating", part.Position)
			Messages:sendClient(player, "AddHunger", 10)
			part:Destroy()
			if not character:FindFirstChild("LeftUpperLeg") and not character:FindFirstChild("RightUpperLeg") then
				character.Humanoid.HipHeight = .5
			end
		end
	end)
	Players.PlayerAdded:connect(function(player)
		player.CharacterAdded:connect(function(character)
			if alienNeeded then
			    if math.random(1, 5) == 1 then
					CollectionService:AddTag(character, "Alien")
					Messages:sendClient(player, "Notify", "You are an alien! Try to consume players without being spotted.")
					Messages:send("GiveTool", player, "Consume")
					player.Backpack["Eat"]:Destroy()
				end
				alienNeeded = false
            end
        end)
	end)
	game:GetService("RunService").Stepped:connect(function()
		if time() - lastAlienNeededSwitch > ALIEN_TIME then
			alienNeeded = true
			lastAlienNeededSwitch = time()
		end
	end)
end

return Alien
