local import = require(game.ReplicatedStorage.Shared.Import)

local player = game.Players.LocalPlayer

local CollectionService = game:GetService("CollectionService")

local function getCharacterHumanoid()
	local character = player.Character
	if character then
		if character:FindFirstChild("Humanoid") then
			return character.Humanoid
		end
	end
end

local effects = {
	{
		tag = "Ragdolled",
		effect = function(humanoid)
			humanoid.PlatformStand = true
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
			if humanoid.Sit == true then
				humanoid.Jump = true
			end
			humanoid.Sit = false
		end,
		doneEffect = function(humanoid)
			humanoid.PlatformStand = false
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
		end,
	}
}

local  UserStatusEffects = {}

local lastHadEffect = {}

function UserStatusEffects:start()
	game:GetService("RunService").RenderStepped:connect(function()
		local humanoid = getCharacterHumanoid()
		if humanoid  and humanoid.Health > 0 then
			--humanoid:SetStateEnabled("Dead", false)
			if not lastHadEffect[humanoid] then
				lastHadEffect[humanoid] = {}
			end
			for _, effect in pairs(effects) do
				if CollectionService:HasTag(humanoid.Parent, effect.tag) then
					if lastHadEffect[humanoid][effect] == false then
						for _, t in pairs(humanoid:GetPlayingAnimationTracks()) do
							t:Stop()
						end
					end
					effect.effect(humanoid)
					lastHadEffect[humanoid][effect] = true
				else
					if lastHadEffect[humanoid][effect] then
						effect.doneEffect(humanoid)
						lastHadEffect[humanoid][effect] = nil
					end
				end
			end
		end
	end)
end

return UserStatusEffects
