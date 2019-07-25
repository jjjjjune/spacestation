local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local AddCash = import "Shared/Utils/AddCash"

local function is(thing, tag)
	return CollectionService:HasTag(thing, tag)
end

return function (murdererPlayer, victimPlayer)
	local victimCharacter = victimPlayer.Character
	local cashBonus = 0
	local playerWasInnocent = true
	if is(victimCharacter, "Murderer") then
		playerWasInnocent = false
		cashBonus = cashBonus + 5
	end
	if is(victimCharacter, "Assaulter") then
		playerWasInnocent = false
		cashBonus = cashBonus + 1
	end
	if is(victimCharacter, "Alien") then
		playerWasInnocent = false
		cashBonus = cashBonus + 5
	end
	if murdererPlayer.Team.Name == "Security" or murdererPlayer.Team.Name == "Space Police" then
		if not playerWasInnocent then
			cashBonus = math.floor(cashBonus*1.5)
		end
	end
	if cash > 0 then
		AddCash(murdererPlayer, cashBonus)
	end
	if playerWasInnocent then
		CollectionService:AddTag(murdererPlayer.Character, "Murderer")
	end
end
