local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local LowerHealth = import "Shared/Utils/LowerHealth"

local FallDamage = {}

function FallDamage:start()
	Messages:hook("CharacterAdded", function(player)
		local character = player.Character
		spawn(function()
			local fallDistance = 0
			local lastY = 1000000
			local currentY = 1000000
			while wait() do
				currentY =character.HumanoidRootPart.Position.Y
				if character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall or character.Humanoid:GetState() == Enum.HumanoidStateType.PlatformStanding or character.Humanoid:GetState() == Enum.HumanoidStateType.Physics and character:FindFirstChild("HumanoidRootPart") then
					if character:FindFirstChild("HumanoidRootPart") and (character.HumanoidRootPart.Velocity.Y < -8) and currentY < lastY then
						fallDistance = fallDistance + math.min(4, lastY - currentY)
					end
				end
				lastY = currentY
				if character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Velocity.Y >= -8 then
					if fallDistance >= 25 then
						local damage = (fallDistance/3)^1.1
						if fallDistance > 50 then
							LowerHealth(character.Humanoid,damage, true)
							if character.Humanoid.Health == 0 then
								character.HumanoidRootPart.Velocity = Vector3.new()
								character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
								character.HumanoidRootPart.CFrame =character.HumanoidRootPart.CFrame * CFrame.Angles(math.random(), math.random(), math.random())
							end
						else
							LowerHealth(character.Humanoid,damage)
						end
						if fallDistance > 40 then
							Messages:send("RagdollCharacter", character, fallDistance/10)
						end
						Messages:send("PlaySound", "BoneBreak", character.Head.Position)
					end
					fallDistance = 0
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
