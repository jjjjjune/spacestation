local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local LowerHealth = import "Shared/Utils/LowerHealth"

local function ragdoll(character)
	if CollectionService:HasTag(character, "Ragdolled") then
		return
	end
	local physicsOwner = game.Players:GetPlayerFromCharacter(character)
	local playerOwner = nil
	if physicsOwner and not playerOwner then
		character.HumanoidRootPart:SetNetworkOwner(physicsOwner)
		Messages:send("RagdollCharacter", character)
		Messages:sendClient(physicsOwner,"RagdollCharacter", character)
	else
		if not playerOwner then
			Messages:send("RagdollCharacter", character)
		else
			Messages:send("RagdollCharacter", character)
			Messages:sendClient(playerOwner,"RagdollCharacter", character)
		end
	end
end

local function unragdoll(character)
	if not CollectionService:HasTag(character, "Ragdolled") then
		return
	end
	local physicsOwner = game.Players:GetPlayerFromCharacter(character)
	local playerOwner = nil
	if physicsOwner and not playerOwner then
		Messages:sendClient(physicsOwner, "UnragdollCharacter", character)
		Messages:send("UnragdollCharacter", character)
		character.HumanoidRootPart:SetNetworkOwner(physicsOwner)
	else
		if not playerOwner then
			Messages:send("UnragdollCharacter", character)
		else
			Messages:sendClient(playerOwner, "UnragdollCharacter", character)
			Messages:send("UnragdollCharacter", character)
		end
	end
end

local Explosions = {}
function Explosions:start()
	Messages:hook("CreateExplosion", function(pos, radius)
		Messages:send("PlaySound", "Explosion", pos)
		local damaged = {}
		local ex = Instance.new("Explosion")
		ex.Position = pos
		ex.Visible = false
		ex.BlastRadius = radius
		ex.DestroyJointRadiusPercent = 0
		ex.BlastPressure = 10000
		ex.Hit:connect(function(hit, dist)
			if hit.Parent:FindFirstChild("Humanoid") and not damaged[hit.Parent] then
				Messages:send("Knockback", hit.Parent, hit.Parent.PrimaryPart.CFrame.lookVector * -(1000/(dist/2)), .4)
				Messages:send("PlaySound", "BoneBreak", hit.Position)
				damaged[hit.Parent] = true
				LowerHealth(nil, hit.Parent, 20)
				ragdoll(hit.Parent)
				delay(3, function()
					unragdoll(hit.Parent)
				end)
				Messages:send("Burn", hit.Parent)
			end
		end)
		local particlePart = game.ReplicatedStorage.Assets.Particles.Explosion:Clone()
		local p = particlePart:Clone()
		p.Parent = workspace
		p.CFrame = CFrame.new(pos)
		for _, v in pairs(p:GetChildren()) do
			v:Emit(15)
		end
		ex.Parent = workspace
		game:GetService("Debris"):AddItem(ex,2)
		game:GetService("Debris"):AddItem(particlePart,2)
	end)
end
return Explosions
