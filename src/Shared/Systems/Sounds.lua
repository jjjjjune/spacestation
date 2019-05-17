local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SoundsFolder = import "Assets/Sounds"

local Sounds = {}

local function makeSoundPart(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new()
    part.Transparency = 1
    part.CanCollide = false
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = workspace
    game:GetService("Debris"):AddItem(part, 5)
    return part
end

local function playSound(soundName, position)
    local sound
    local part

    if position then
        part = makeSoundPart(position)
        sound = SoundsFolder[soundName]:Clone()
    else
        sound = SoundsFolder[soundName]:Clone()
    end
    sound.Parent = part or workspace
    sound:Play()
end

function Sounds:start()
	Messages:hook("PlaySoundServer", function(player, soundName, position)
        playSound(soundName, position)
    end)

    Messages:hook("PlaySound", function(soundName, position)
        playSound(soundName, position)
    end)

    Messages:hook("PlaySoundClient", function(soundName)
        playSound(soundName)
    end)
end


return Sounds
