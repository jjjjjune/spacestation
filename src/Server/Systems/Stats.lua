--[[
	hnadlers hunger and thirst
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local Players = game:GetService("Players")

local Store = import "Shared/State/Store"
local Replicate, ReplicateTo = import("Shared/State/Replication", { "replicate", "replicateTo" })
local SetHunger = import "Shared/Actions/PlayerStats/SetHunger"
local SetThirst = import "Shared/Actions/PlayerStats/SetThirst"
local SetTimeAlive = import "Shared/Actions/PlayerStats/SetTimeAlive"
local Constants = import "Shared/Data/StatConstants"
local Messages = import "Shared/Utils/Messages"
local Data = import "Shared/PlayerData"
local CollectionService = game:GetService("CollectionService")
local LowerHealth = import "Shared/Utils/LowerHealth"
local PhysicsService = game:GetService("PhysicsService")

local lastCarry = {}
local ragdollOverride = {}

local Stats = {}

local function isBeingCarried(character)
	return character:FindFirstChild("CarryRope", true)
end

local function isCarryingSomeone(character)
	for _, checkChar in pairs(CollectionService:GetTagged("Ragdolled")) do
		if checkChar:FindFirstChild("CarrierValue") then
			if checkChar.CarrierValue.Value == character then
				return checkChar
			end
		end
	end
end

local function releaseCarried(player)
	local char = isCarryingSomeone(player.Character)
	if char then
		lastCarry[char] = time()
		char:FindFirstChild("CarryRope", true):Destroy()
		char:FindFirstChild("CarrierValue", true):Destroy()
	end
end

local playingAnims = {}

local function makeRagdoll(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	if player then
		releaseCarried(player)
	end
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, "RagdollGroup")
			if part.Name ~= "HumanoidRootPart" then
				part.Massless = true
			end
			part.CanCollide = true
			if character:FindFirstChild("CarrierValue") then
				part:SetNetworkOwner(game.Players:GetPlayerFromCharacter(character.CarrierValue.Value))
			end
		end
	end
	if isBeingCarried(character) then
		Data:set(player, "lastHit", time())
	end
	if (not playingAnims[character]) and (isBeingCarried(character)) then
		spawn(function() Messages:send("PlayAnimation", character, "KickingLegs") end)
		playingAnims[character] = true
	else
		spawn(function() Messages:send("StopAnimation", character, "KickingLegs") playingAnims[character] = nil end)
	end
end

local function unmakeRagdoll(character)
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, "CharacterGroup")
			if part.Name ~= "HumanoidRootPart" then
				part.Massless = false
			end
			part:SetNetworkOwner(game.Players:GetPlayerFromCharacter(character))
		end
	end
	Messages:send("StopAnimation", character, "KickingLegs")
	playingAnims[character] = nil
end

local function canBeCarried(carrier, target)
	if CollectionService:HasTag(target, "Ragdolled")  and target.Humanoid.Health < 4 then
		if not isBeingCarried(target) then
			if (carrier.HumanoidRootPart.Position - target.HumanoidRootPart.Position).magnitude < 12 then
				return true
			end
		end
	end
	return false
end

local function checkRagdoll(character)
	if character.Humanoid.Health < 4 then
		CollectionService:AddTag(character, "Ragdolled")
		makeRagdoll(character)
	else
		local override = ragdollOverride[character]
		if override then
			if time() - override.start < override.length then
				CollectionService:AddTag(character, "Ragdolled")
				makeRagdoll(character)
			else
				ragdollOverride[character] = nil
			end
		else
			if not isBeingCarried(character) then
				local canRemove = true
				if lastCarry[character] then
					if time() - lastCarry[character] < 5 then
						canRemove = false
					end
				end
				if canRemove == true then
					CollectionService:RemoveTag(character, "Ragdolled")
					unmakeRagdoll(character)
					local rope = character:FindFirstChild("CarryRope", true)
					if rope then
						rope:Destroy()
					end
				end
			end
		end
	end
end

local function startLoops()
	spawn(function()
		while wait() do
			for _, player in pairs(game.Players:GetPlayers()) do
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					checkRagdoll(player.Character)
				end
			end
		end
	end)
	spawn(function()
		while wait(1) do
			for _, player in pairs(game.Players:GetPlayers()) do
				Data:add(player, "timeAlive", 1)
				if player.Character then
					local hum = player.Character:FindFirstChild("Humanoid")
					if hum and player.Character:FindFirstChild("HumanoidRootPart") then
						Data:set(player, "health", hum.Health)
						Data:set(player, "position", {
							x = player.Character.HumanoidRootPart.Position.X,
							y = player.Character.HumanoidRootPart.Position.Y,
							z = player.Character.HumanoidRootPart.Position.Z,
						})
					end
				end
			end
		end
	end)
	spawn(function()
		while wait(Constants.HUNGER_DECAY) do
			for _, player in pairs(game.Players:GetPlayers()) do
				local character = player.Character
				if character then
					local userId = tostring(player.UserId)
					local state = Store:getState()
					local myHunger = state.playerStats[userId].hunger
					Store:dispatch(ReplicateTo(player, SetHunger(userId, math.max(0,myHunger - 1))))
					Data:set(player, "hunger", myHunger-1)
					if myHunger <= 0 then
						character.Humanoid:TakeDamage(Constants.HUNGER_DAMAGE)
					else
						character.Humanoid.Health = character.Humanoid.Health + (myHunger/60)
					end
					if CollectionService:HasTag(character, "Poisoned") then
						Data:set(player, "lastHit", time())
						LowerHealth(character.Humanoid, Constants.POISON_DAMAGE, true)
					end
				end
			end
		end
	end)
	spawn(function()
		while wait(Constants.THIRST_DECAY) do
			for _, player in pairs(game.Players:GetPlayers()) do
				local userId = tostring(player.UserId)
				local state = Store:getState()
				local myThirst = state.playerStats[userId].thirst
				Store:dispatch(ReplicateTo(player, SetThirst(userId, math.max(0,myThirst - 1))))
				Data:set(player, "thirst", myThirst-1)
				if myThirst <= 0 then
					player.Character.Humanoid:TakeDamage(Constants.THIRST_DAMAGE)
				else
					if player.Character then
						player.Character.Humanoid.Health = player.Character.Humanoid.Health + (myThirst/60)
					end
				end
			end
		end
	end)
end



function Stats:start()
	Messages:hook("PlayerDied", function(player)
		local userId = tostring(player.UserId)
		Store:dispatch(ReplicateTo(player, SetHunger(userId, 100)))
		Store:dispatch(ReplicateTo(player, SetThirst(userId, 100)))
		Store:dispatch(ReplicateTo(player, SetTimeAlive(userId, 0)))
		Data:set(player, "timeAlive", 0)
	end)
	Messages:hook("PlayerAdded", function(player)
		local userId = tostring(player.UserId)
		local hunger = Data:get(player, "hunger")
		local thirst = Data:get(player, "thirst")
		Store:dispatch(ReplicateTo(player, SetHunger(userId, hunger)))
		Store:dispatch(ReplicateTo(player, SetThirst(userId, thirst)))
		spawn(function()
			repeat wait() until player.Character
			player.Character:WaitForChild("Humanoid").Health = Data:get(player, "health")
		end)
	end)
	Messages:hook("DrinkWater", function(player, water)
		if water.Quantity.Value > 0 then
			water.Quantity.Value = water.Quantity.Value - 1
			local userId = tostring(player.UserId)
			local state = Store:getState()
			local myThirst = state.playerStats[userId].thirst
			Store:dispatch(ReplicateTo(player, SetThirst(userId, math.min(100, math.max(0,myThirst + 1)))))
			Data:set(player, "thirst", myThirst+1)
			Messages:send("PlaySound", "Drinking", player.Character.HumanoidRootPart.Position)
		end
	end)
	Messages:hook("RagdollCharacter", function(char,duration)
		ragdollOverride[char] = {start = time(), length = duration}
	end)
	Messages:hook("CarryCharacter", function(player, targetCharacter)
		local playerCharacter = player.Character
		if isCarryingSomeone(playerCharacter) then
			releaseCarried(player)
			return
		end
		if canBeCarried(playerCharacter, targetCharacter) then
			local Attach1 = Instance.new("Attachment", targetCharacter.Head)
			local Attach2 = Instance.new("Attachment", playerCharacter.HumanoidRootPart)
			local Rope = Instance.new("RopeConstraint", targetCharacter.Head)
			Rope.Name = "CarryRope"
			Rope.Attachment0 = Attach1
			Rope.Attachment1 = Attach2
			Rope.Length = 9
			Rope.Visible = true
			local owner = Instance.new("ObjectValue", targetCharacter)
			owner.Name = "CarrierValue"
			owner.Value = playerCharacter
		end
	end)
	Messages:hook("RagdollMe", function(player)
		ragdollOverride[player.Character] = {start = time(), length = 20}
	end)
	Messages:hook("PlayerDied", function(player)
		releaseCarried(player)
	end)
	startLoops()
end

return Stats
