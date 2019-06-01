local import = require(game.ReplicatedStorage.Shared.Import)

local CombatConstants = import "Shared/Data/CombatConstants"
local EquipmentConstants = import "Shared/Data/EquipmentConstants"
local WeaponData = import "Shared/Data/WeaponData"
local Messages = import "Shared/Utils/Messages"
local Store = import "Shared/State/Store"
local LowerHealth = import "Shared/Utils/LowerHealth"
local CollectionService = game:GetService("CollectionService")
local PlayerData = import "Shared/PlayerData"
local GetPlayerDamage = import "Shared/Utils/GetPlayerDamage"
local HttpService = game:GetService("HttpService")

local Combat ={}

local stunLockedTable = {}
local shieldUpTable = {}
local shieldHitCountTable = {}
local swingTable = {}
local alreadyDead = {}

local function getAngleRelativeToPlayer(character, target)
	local originPart = character.HumanoidRootPart
	local toTargetDirection = (target - originPart.Position).unit
	local targetAngle = originPart.CFrame.lookVector:Dot(toTargetDirection)
	return math.deg(math.acos(targetAngle))
end

local function getEnemies(character, range, angle)
	local enemies = {}
	local inserted = {}
	local vec1 = (character.HumanoidRootPart.Position + Vector3.new(-range,-(range*4),-range))
	local vec2 = (character.HumanoidRootPart.Position + Vector3.new(range,(range*4),range))
	local region = Region3.new(vec1, vec2)
	local parts = workspace:FindPartsInRegion3(region,nil, 10000)
	for _, part in pairs(parts) do
		local humanoid = part.Parent:FindFirstChild("Humanoid")
		if not CollectionService:HasTag(part.Parent, "Ragdolled") then
			if humanoid and (humanoid ~= character.Humanoid) then
				local ang = getAngleRelativeToPlayer(character, part.Position)
				if ang < angle then
					if not inserted[humanoid] then
						table.insert(enemies, {humanoid = humanoid, part = part})
						inserted[humanoid] = true
					end
				end
			end
		end
	end
	return enemies
end

local function getInventory(player)
	local state = Store:getState()
	local inventory = state.inventories[tostring(player.UserId)]
	return inventory
end

local function getEquipmentSlot(inventory, tagName)
	local slotNumber = "1"
	for slot, data in pairs(EquipmentConstants.SLOT_EQUIPMENT_DATA) do
		if data.tag == tagName then
			slotNumber = slot
		end
	end
	return inventory[slotNumber]
end

local function getWeaponData(player)
	local inventory = getInventory(player)
	local sword = getEquipmentSlot(inventory, "Sword")
	return WeaponData[sword] or WeaponData["Default"]
end

local function getShieldData(player)
	local inventory = getInventory(player)
	local shield = getEquipmentSlot(inventory, "Shield")
	return WeaponData[shield] or WeaponData["Default"]
end

local function raiseShield(character)
	shieldUpTable[character] = true
end

local function setShield(character, isUp)
	if isUp then
		local lastStunLocked = stunLockedTable[character] or 0
		if (time() - lastStunLocked) > (CombatConstants.STUN_LOCK_TIME - CombatConstants.SERVER_FORGIVENESS) then
			raiseShield(character)
			shieldHitCountTable[character] = 0
		end
	else
		shieldUpTable[character] = false
		shieldHitCountTable[character] = 0
	end
end

local function stunLock(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	stunLockedTable[character] = time()
	Messages:send("PlayAnimation", character, "StunLock")
	Messages:sendClient(player, "StunLocked")
end

local function isStunLocked(character)
	local lastLock = stunLockedTable[character]
	if lastLock then
		if time() - lastLock < (CombatConstants.STUN_LOCK_TIME - CombatConstants.SERVER_FORGIVENESS) then
			return true
		end
	end
	return false
end

local function knockback(character, amount, direction)
	local player = game.Players:GetPlayerFromCharacter(character)
	if player then
		Messages:sendClient(player, "Knockback", amount, direction)
	end
end

local function isBehind(attacker, victim)
	local angle = getAngleRelativeToPlayer(victim, attacker.HumanoidRootPart.Position)
	if angle > 130 then
		return true
	end
end

local function isPositionBehind(position, victim)
	local angle = getAngleRelativeToPlayer(victim, position)
	if angle > 130 then
		return true
	end
end

local function damageCharacter(character, attackerCharacter, weaponData, part)
	local blocked = false
	if shieldUpTable[character] == true and not isBehind(attackerCharacter, character) then
		local hitAmount = shieldHitCountTable[character]
		shieldHitCountTable[character] = (hitAmount and hitAmount + weaponData.guardDamage) or 1
		local player = game.Players:GetPlayerFromCharacter(character)
		local shieldData = getShieldData(player)
		if hitAmount >= shieldData.guardLength then
			Messages:sendClient(player, "GuardBroken")
			Messages:send("PlayAnimation", character, "GuardBreak")
			shieldUpTable[character] = false
			Messages:send("PlaySound", "HitStrong", character.HumanoidRootPart.Position)
			blocked = true
		else
			Messages:send("PlayAnimation", character, "Hit2")
			Messages:send("PlaySound", weaponData.damageSound, character.HumanoidRootPart.Position)
			knockback(character, weaponData.knockback/2, attackerCharacter.HumanoidRootPart.CFrame.lookVector)
			blocked = true
		end
	end
	if not blocked then
		local attackerPlayer = game.Players:GetPlayerFromCharacter(attackerCharacter)
		LowerHealth(character.Humanoid, GetPlayerDamage(attackerPlayer))
		stunLock(character)
		Messages:send("PlaySound", "HitSword", character.HumanoidRootPart.Position)
		shieldHitCountTable[character] = 0
		Messages:send("PlayParticle", "Shine", 1, part.Position)
		local victim = game.Players:GetPlayerFromCharacter(character)
		PlayerData:set(victim, "lastHit", time())
	else
		Messages:send("PlayParticle", "Sparks",20,part.Position)
	end
	knockback(character, weaponData.knockback, attackerCharacter.HumanoidRootPart.CFrame.lookVector)
end

local function attemptDamage(character, attackerCharacter,weaponData, part)
	if CollectionService:HasTag(character, "Character") then
		damageCharacter(character, attackerCharacter, weaponData, part)
	else
		local attackerPlayer = game.Players:GetPlayerFromCharacter(attackerCharacter)
		Messages:send("PlayerTriedDamageMonster", attackerPlayer, character, weaponData, part)
		if character.Humanoid.Health <= 0 then
			if not alreadyDead[character] then
				alreadyDead[character] = true
			end
			PlayerData:add(attackerPlayer, character.Name.."Killed", 1)
		end
	end
end

local function canSwing(character, swingSpeed)
	if not swingTable[character] then
		swingTable[character] = time() - 100
	end
	if time() - swingTable[character] >= (swingSpeed - CombatConstants.SERVER_FORGIVENESS) then
		return true
	end
end

local function swing(attackerCharacter, weaponData)
	local enemies = getEnemies(attackerCharacter, weaponData.range, weaponData.angle)
	for _, partTab in pairs(enemies) do
		local character = partTab.humanoid.Parent
		attemptDamage(character,attackerCharacter, weaponData, partTab.part)
	end
end

local function attemptSwing(character, isLunge)
	local player = game.Players:GetPlayerFromCharacter(character)
	local weaponData = getWeaponData(player)
	if character.Head.Position.Y > 1000 then
		-- in hell maybe
		return
	end
	if canSwing(character, weaponData.swingSpeed) then
		swingTable[character] = time()
		spawn(function() -- using this rn to make up for the fact that i dont have keyframeReached
			if not isLunge then
				wait(weaponData.chargeTime)
			end
			if not isStunLocked(character) then
				swing(character, weaponData)
				local inventory = getInventory(player)
				local sword = getEquipmentSlot(inventory, "Sword")
				if sword then
					local itemModel = character:FindFirstChild(sword)
					local trail = itemModel and itemModel:FindFirstChild("Trail", true)
					if trail then
						trail.Enabled = true
						spawn(function()
							wait(.5)
							trail.Enabled = false
						end)
					end
				end
			end
		end)
	end
end

local function executeCharacter(executorPlayer, character)
	local executor = executorPlayer.Character
	if CollectionService:HasTag(character, "Ragdolled") and not CollectionService:HasTag(character, "Dead") then
		if character.Humanoid.Health < 4 then
			if (executor.HumanoidRootPart.Position - character.HumanoidRootPart.Position).magnitude < 12 then
				CollectionService:AddTag(character, "Dead")
				Messages:send("PlayAnimation", executor, "SwingFinal")
				spawn(function()
					wait(.45)
					LowerHealth(character.Humanoid,1000, true)
					Messages:send("PlaySound", "Execute", character.Head.Position)
					character:BreakJoints()
					PlayerData:add(executorPlayer, "playersExecutedTotal", 1)
				end)
			end
		end
	end
end

function Combat:start()
	Messages:hook("DebugStunLock", function(player)
		stunLock(player.Character)
	end)
	Messages:hook("DamageHumanoid", function(humanoid, damage, projectileName)
		if not shieldUpTable[humanoid.Parent] then
			print("damaging", damage)
			LowerHealth(humanoid, damage, true)
		else
			local character = humanoid.Parent
			local blocked = false
			local hitAmount = shieldHitCountTable[character]
			shieldHitCountTable[character] = (hitAmount and hitAmount + 1) or 1
			local player = game.Players:GetPlayerFromCharacter(character)
			local shieldData = getShieldData(player)
			if hitAmount >= shieldData.guardLength then
				Messages:sendClient(player, "GuardBroken")
				Messages:send("PlayAnimation", character, "GuardBreak")
				shieldUpTable[character] = false
				Messages:send("PlaySound", "HitStrong", character.HumanoidRootPart.Position)
				blocked = false
			else
				Messages:send("PlayAnimation", character, "Hit2")
				Messages:send("PlaySound", "HitSlap", character.HumanoidRootPart.Position)
				knockback(character, 2, character.HumanoidRootPart.CFrame.lookVector * Vector3.new(1,1,-1))
				blocked = true
			end
			if not blocked then
				print("did nbot block")
				LowerHealth(humanoid, damage, true)
			else
				print("did block")
				if projectileName then
					print("richochet")
					-- ricochet!!!
					local id = HttpService:GenerateGUID()
					local pos = humanoid.RootPart.Position
					local goal = (humanoid.RootPart.CFrame * CFrame.new(0,30,-200)).p
					local model = game.ReplicatedStorage.Assets.Items[projectileName]:Clone()
					local player = game.Players:GetPlayerFromCharacter(character)
					Messages:send("CreateProjectile", id, pos, goal, model, humanoid.Parent, player)
				end
			end
		end
	end)
	Messages:hook("Swing", function(player, isLunge)
		if CollectionService:HasTag(player.Character, "Ragdolled") then
			return
		end
		attemptSwing(player.Character, isLunge)
	end)
	Messages:hook("SetShieldUp", function(player, isShieldUp)
		setShield(player.Character, isShieldUp)
	end)
	Messages:hook("ExecuteCharacter", function(executor, character)
		spawn(function()
			executeCharacter(executor, character)
		end)
	end)
end

return Combat
