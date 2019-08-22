local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local LowerHealth = import "Shared/Utils/LowerHealth"
local ObjectReactions = import "Shared/Data/ObjectReactions"

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

local function onExplosionHit(hit, dist, damaged)
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
	if CollectionService:HasTag(hit.Parent, "Machine") then
		Messages:send("BreakMachine", hit.Parent)
	end
	if ObjectReactions[hit.Parent.Name] then
		if ObjectReactions[hit.Parent.Name].HEAT == "EXPLODE" and not CollectionService:HasTag(hit.Parent, "Chained") then
			spawn(function()
				CollectionService:AddTag(hit.Parent, "Chained")
				wait(.25)
				Messages:send("CreateExplosion", hit.Position, 20)
				hit.Parent:Destroy()
			end)
		end
	end
	if CollectionService:HasTag(hit.Parent, "Door") then
		Messages:send("ForceOpenDoor", hit.Parent)
	end
	if CollectionService:HasTag(hit.Parent, "Engine") then
		if not damaged[hit.Parent] then
			damaged[hit.Parent] = true
			Messages:send("DamageEngine", math.max(0, 50 - dist))
		end
	end
	if CollectionService:HasTag(hit.Parent, "Vehicle") then
		Messages:send("DestroyVehicle", hit.Parent)
	end
	if CollectionService:HasTag(hit.Parent, "Supply") then
		for _ = 1, hit.Parent.Quantity.Value do
			Messages:send("OrderSupply", hit.Parent)
		end
	end
end

local Explosions = {}
function Explosions:start()
	Messages:hook("CreateExplosion", function(pos, radius)
		Messages:send("PlaySound", "Explosion", pos)
		local ex = Instance.new("Explosion")
		ex.Position = pos
		ex.Visible = false
		ex.BlastRadius = radius
		ex.DestroyJointRadiusPercent = 0
		ex.BlastPressure = 10000
		local damaged = {}
		ex.Hit:connect(function(hit, dist)
			onExplosionHit(hit, dist, damaged)
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
