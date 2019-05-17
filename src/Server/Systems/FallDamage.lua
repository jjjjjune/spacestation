local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local LowerHealth = import "Shared/Utils/LowerHealth"

local FallDamage = {}

function FallDamage:start()
	Messages:hook("CharacterAdded", function(player)
		local character = player.Character
		spawn(function()
			local fallTime = 0
			local lastY = 1000000
			while true do
				local x = wait()
				if character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall or character.Humanoid:GetState() == Enum.HumanoidStateType.PlatformStanding or character.Humanoid:GetState() == Enum.HumanoidStateType.Physics and character:FindFirstChild("HumanoidRootPart") then
					if character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Velocity.Y < -13 then
						fallTime = fallTime + x
						lastY = character.HumanoidRootPart.Position.Y
					end
				end
				if character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Velocity.Y >= -13 then
					if fallTime >= .5 then
						local damage = (fallTime*6)^2.5
						if fallTime > 1 then
							LowerHealth(character.Humanoid,damage, true)
							if character.Humanoid.Health == 0 then
								character.HumanoidRootPart.Velocity = Vector3.new()
								character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
								character.HumanoidRootPart.CFrame =character.HumanoidRootPart.CFrame * CFrame.Angles(math.random(), math.random(), math.random())
							end
						else
							LowerHealth(character.Humanoid,damage)
						end
						if fallTime > .6 then
							Messages:send("RagdollCharacter", character, fallTime * 6)
						end
						Messages:send("PlaySound", "BoneBreak", character.Head.Position)
					end
					fallTime = 0
					lastY = 100000000
				end
				if character.Parent == nil then
					break
				end
			end
		end)
	end)
end



return FallDamage
