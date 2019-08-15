local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local HasContraband = import "Shared/Utils/HasContraband"

local lastBeep = {}

local function beep(checkpoint, character)
	if not lastBeep[character] then
		lastBeep[character] = time()
	else
		if time() - lastBeep[character] < 1 then
			return
		else
			lastBeep[character] = time()
		end
	end
	local player = game.Players:GetPlayerFromCharacter(character)
	if HasContraband(player) or CollectionService:HasTag(character, "Alien") then
		CollectionService:AddTag(character,"Searched")
		Messages:send("PlaySound","Error", character.PrimaryPart.Position)
		spawn(function()
			for _, possibleLight in pairs(checkpoint:GetChildren()) do
				if possibleLight.Name == "Light" then
					possibleLight.BrickColor = BrickColor.new("Terra Cotta")
				end
			end
			wait(.4)
			for _, possibleLight in pairs(checkpoint:GetChildren()) do
				if possibleLight.Name == "Light" then
					possibleLight.BrickColor = BrickColor.new("Olivine")
				end
			end
		end)
	else
		Messages:send("PlaySound","Chime", character.PrimaryPart.Position)
		CollectionService:RemoveTag(character,"Searched")
	end
end

local function onCharacterTouchedCheckpoint(character, checkpoint)
	local player = game.Players:GetPlayerFromCharacter(character)
	if player then
		beep(checkpoint, character)
	end
end

local Checkpoints = {}

function Checkpoints:start()
	for _, checkpoint in pairs(CollectionService:GetTagged("Checkpoint")) do
		checkpoint.Hitbox.Touched:connect(function(hit)
			if hit.Parent:FindFirstChild("Humanoid") then
				onCharacterTouchedCheckpoint(hit.Parent, checkpoint)
			end
		end)
	end
end

return Checkpoints
