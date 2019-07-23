local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local Animations = {}

local characterToTracksTable = {}

local function getTrack(character, animationName)
	if not character.Humanoid:IsDescendantOf(game) then
		repeat wait() until character.Humanoid:IsDescendantOf(game)
	end
    if not character:FindFirstChild(animationName) then
        return
    end
    if not characterToTracksTable[character] then
        characterToTracksTable[character] = {}
    end
	if not characterToTracksTable[character][animationName] then
		characterToTracksTable[character][animationName] = character.Humanoid:LoadAnimation(character[animationName])
    end
    return characterToTracksTable[character][animationName]
end

function Animations:start()
	Messages:hook("PlayAnimationClient", function(animationName)
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            if not character:FindFirstChild(animationName) then
                Messages:sendServer("PlayAnimationServer", animationName)
                return
			end
			getTrack(character, animationName):Play()
        end
    end)
    Messages:hook("StopAnimationClient", function(animationName)
        local player = game.Players.LocalPlayer
        local character = player.Character
        local track = getTrack(character, animationName)
        if track then
            track:Stop()
            Messages:sendServer("StopAnimationServer", animationName)
        end
    end)
end


return Animations
