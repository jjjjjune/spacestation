local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")

local function makeVisible(character, originalTransparencies)
	Messages:send("PlayParticle", "Smoke", 15, character.PrimaryPart.Position)
	Messages:send("PlaySound", "Smoke", character.PrimaryPart.Position)
    CollectionService:RemoveTag(character, "vanished")
    for _, p in pairs(character:GetDescendants()) do
        if p:IsA("BasePart") then
			p.Transparency = originalTransparencies[p]
			p.Material = Enum.Material.SmoothPlastic
        elseif p:IsA("BillboardGui") then
			p.Enabled = true
		elseif p:IsA("Decal") then
			p.Transparency = 0
        end
    end
end

local function makeInvisible(character, t)
    if CollectionService:HasTag(character, "vanished") then
        return
    end
	Messages:send("PlayParticle", "Smoke", 15, character.PrimaryPart.Position)
	Messages:send("PlaySound", "Smoke", character.PrimaryPart.Position)
    local originalTransparencies = {}
    spawn(function()
		CollectionService:AddTag(character, "vanished")
		local startHealth = 100
		if character:FindFirstChild("Humanoid") then
			startHealth = character.Humanoid.Health
		end
        for _, p in pairs(character:GetDescendants()) do
            if p:IsA("BasePart") then
				originalTransparencies[p] = p.Transparency
				p.Material = Enum.Material.Glass
                p.Transparency = 1
            elseif p:IsA("BillboardGui") then
				p.Enabled = false
			elseif p:IsA("Decal") then
				p.Transparency = 1
            end
		end
        for _ = 1, 240 do
			wait(t/240)
			if character:FindFirstChild("Humanoid") then
				if character.Humanoid.Health < startHealth then
					makeVisible(character, originalTransparencies)
					return
				elseif character.Humanoid.Health > startHealth then
					startHealth = character.Humanoid.Health
				end
			end
        end
        makeVisible(character, originalTransparencies)
    end)
end

local Invisiblity = {}
function Invisiblity:start()
	Messages:hook("TurnInvisible",function(character, t)
		makeInvisible(character, t)
	end)
end
return Invisiblity
