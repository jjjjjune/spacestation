
local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CombatConstants = import "Shared/Data/CombatConstants"
local EquipmentConstants = import "Shared/Data/EquipmentConstants"
local WeaponData = import "Shared/Data/WeaponData"
local GetRaceInfo = import "Shared/Utils/GetRaceInfo"
local WorldConstants = import "Shared/Data/WorldConstants"
local Store = import "Shared/State/Store"
local ItemsUtil = import "Shared/Utils/Items"

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Combat = {}

local player = game.Players.LocalPlayer
local comboCount = 0
local lastSwing =time()
local shieldUp = false
local shieldPutDown = time()
local lastHit = time()
local animationIterator = 0
local mouse2Down = false
local lastSwingAnimation = "Swing1"
local guardBroken = time()

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

local function getWeaponData()
	local inventory = getInventory(player)
	local sword = getEquipmentSlot(inventory, "Sword")
	return WeaponData[sword] or WeaponData["Default"]
end

local function getShieldData()
	local inventory = getInventory(player)
	local sword = getEquipmentSlot(inventory, "Shield")
	return WeaponData[sword] or WeaponData["Default"]
end


local function stunLocked()
	if (time() - lastHit) < CombatConstants.STUN_LOCK_TIME then
		return true
	end
end

local function inWater()
	local root = player.Character.HumanoidRootPart
	local r = Ray.new(root.Position + Vector3.new(0,6,0), Vector3.new(0,-13,0))
	local hit, pos = workspace:FindPartOnRay(r, root.Parent)
	if hit and hit == workspace.Terrain then
		return true
	end
end

local function getWalkspeed()
	local weaponData = getWeaponData()
	if not weaponData then
		return 16
	end
	if stunLocked() then
		return CombatConstants.STUN_LOCK_WALKSPEED
	end
	--[[if shieldUp then
		return weaponData.shieldWalkspeed
	end--]]
	if time() - lastSwing < weaponData.swingSpeed then
		return weaponData.swingWalkspeed
	end
	local waterModifier =1
	local baseWalkspeed = GetRaceInfo(_G.Data["race"]).walkSpeed
	local weaponModifier = weaponData.wieldSpeedModifier
	--[[local shieldData = getShieldData()
	local shieldModifier = shieldData.wieldSpeedModifier--]]
	local shieldModifier = 0
	if (player.Character:FindFirstChild("HumanoidRootPart")) and (player.Character.HumanoidRootPart.Position.Y < WorldConstants.WATER_LEVEL) and inWater() then
		waterModifier = CombatConstants.SWIM_SPEED_MODIFIER
	end
	return (baseWalkspeed + weaponModifier + shieldModifier) * waterModifier
end

local function getJumpPower()
	local basePower = GetRaceInfo(_G.Data["race"]).jumpPower
	if stunLocked() then
		return 0
	end
	return basePower
end

local function manageWalkspeed()
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = getWalkspeed()
			humanoid.JumpPower = getJumpPower()
		end
	end
end

local function getSwingDebounce(weaponData)
	local debounce = weaponData.swingSpeed

	if comboCount == 0 then
		-- if we have finished the combo, set the recover time to the post combo speed
		debounce = weaponData.postComboSwingSpeed
	end

	return debounce
end

local function attemptSwing()
	if stunLocked() or shieldUp then
		return
	end

	local weaponData = getWeaponData()
	local debounce = getSwingDebounce(weaponData)

	if (time() - lastSwing > CombatConstants.COMBO_BREAK_TIME) then
		comboCount = 0
		animationIterator = 0
		-- if it has been too long since the last hit, break the combo
	end

	if time() - lastSwing > debounce then
		lastSwing = time()
		local animNumber = (animationIterator%2)+1
		lastSwingAnimation = "Swing"..animNumber
		if comboCount == weaponData.comboLength - 1 then
			lastSwingAnimation = "SwingFinal"
		end
		Messages:sendServer("Swing")
		Messages:send("PlayAnimationClient", lastSwingAnimation)
		spawn(function()wait(weaponData.chargeTime)
			Messages:sendServer("PlaySoundServer", weaponData.swingSound, player.Character.HumanoidRootPart.Position)
		end)
		comboCount = comboCount + 1
		animationIterator = animationIterator + 1
		if comboCount == weaponData.comboLength then
			comboCount = 0
			animationIterator = 0
		end
		shieldPutDown = time()
	end
end

local function attemptRaiseShield()
	-- as long as right click is down it will try to raise your shield
	if stunLocked() then
		return
	end
	if time() - guardBroken < CombatConstants.GUARD_RECOVERY then
		return
	end
	if (time() - shieldPutDown > CombatConstants.SHIELD_DEBOUNCE) and not shieldUp then
		Messages:sendServer("SetShieldUp", true)
		Messages:send("PlayAnimationClient", "ShieldUp")
		shieldUp = true
	end
end

local function lowerShield()
	shieldPutDown = time()
	if shieldUp == true then
		Messages:sendServer("SetShieldUp", false)
		Messages:send("StopAnimationClient", "ShieldUp")
		shieldUp = false
	end
end

local function lunge()
	if not stunLocked() and not shieldUp then
		if (time() - shieldPutDown > CombatConstants.SHIELD_DEBOUNCE) then
			local weaponData = getWeaponData()
			if (time() - lastSwing) > getSwingDebounce(weaponData) then
				Messages:send("PlayAnimationClient", "Lunge")
				local force = player.Character.HumanoidRootPart.BodyVelocity
				local flat = Vector3.new(1,0,1)
				spawn(function()
					wait(.2)
					force.MaxForce = Vector3.new(100000,0,100000)
					force.Velocity = (player.Character.HumanoidRootPart.CFrame.lookVector * flat * 73)
					wait(.3)
					Messages:sendServer("Swing", true)
					lastSwing = time()
					shieldPutDown = time()
					force.MaxForce = Vector3.new(0,0,0)
					force.Velocity = Vector3.new()
					-- using a lunge results in having a bit of time before you can swing or shield again
				end)
				shieldPutDown = time()
				lastSwing = time()
			end
		end
	end
end

local function nearbyRagdolledCharacter()
	local char = ItemsUtil.getNearestTagToPosition("Ragdolled", player.Character.HumanoidRootPart.Position, 12)
	if char == player.Character then
		return nil
	end
	return char
end

function Combat:start()
	Messages:hook("GuardBroken", function()
		shieldPutDown = time()
		guardBroken = time()
		lowerShield()
	end)
	Messages:hook("StunLocked", function()
		lastHit = time()
		lowerShield()
	end)
	Messages:hook("Knockback", function(amount, direction)
		player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + (direction*amount)
	end)
	UserInputService.InputBegan:connect(function(inputObject, gameProcessed)
		if inputObject.KeyCode == Enum.KeyCode.R and not gameProcessed then
			Messages:sendServer("CarryCharacter", nearbyRagdolledCharacter())
		end
		if inputObject.KeyCode == Enum.KeyCode.X then
			Messages:sendServer("ExecuteCharacter", nearbyRagdolledCharacter())
		end
		if inputObject.KeyCode == Enum.KeyCode.Q and not gameProcessed then
			if CollectionService:HasTag(player.Character, "Ragdolled") then
				return
			end
			lunge()
		end
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
			if CollectionService:HasTag(player.Character, "Ragdolled") then
				return
			end
			attemptSwing()
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
			mouse2Down = true
		end
	end)
	UserInputService.InputEnded:connect(function(inputObject, gameProcessed)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
			mouse2Down = false
			lowerShield()
		end
	end)
	RunService.RenderStepped:connect(function()
		if mouse2Down or player.Name == "Player2" then
			attemptRaiseShield()
		end
		manageWalkspeed()
		if shieldUp then
			local flat = Vector3.new(1,0,1)
			local character = player.Character
			local direction = workspace.CurrentCamera.CFrame.lookVector
			if character:FindFirstChild("Humanoid") then
				--local y = Vector3.new(0, character.HumanoidRootPart.Position.Y,0)
				--character.HumanoidRootPart.CFrame = CFrame.new((character.HumanoidRootPart.Position*flat) + y, ((character.HumanoidRootPart.CFrame + direction*5).p*flat)+ y)
			end
		end
	end)
end

return Combat
