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
			local lastForce = 0
			while wait() do
				currentY =character.HumanoidRootPart.Position.Y
				local changeInForce = math.abs(lastForce - character.HumanoidRootPart.Velocity.Y)
				if character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall or character.Humanoid:GetState() == Enum.HumanoidStateType.PlatformStanding or character.Humanoid:GetState() == Enum.HumanoidStateType.Physics and character:FindFirstChild("HumanoidRootPart") then
					if character:FindFirstChild("HumanoidRootPart") and currentY < lastY then
						fallDistance = fallDistance + math.min(4, lastY - currentY)
						lastForce = character.HumanoidRootPart.Velocity.Y
					elseif currentY > lastY then
						fallDistance = 0
					end
				end
				lastForce = character.HumanoidRootPart.Velocity.Y
				lastY = currentY
				if changeInForce > 100000000 then
					changeInForce = 0
				end
				if character:FindFirstChild("HumanoidRootPart") and changeInForce > 80  then
					if changeInForce >= 80 then
						local damage = (math.abs(changeInForce)/6)^1.15
						print(damage, changeInForce)
						if changeInForce > 130 then
							LowerHealth(character.Humanoid,damage, true)
							if character.Humanoid.Health == 0 then
								character.HumanoidRootPart.Velocity = Vector3.new()
								character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
								character.HumanoidRootPart.CFrame =character.HumanoidRootPart.CFrame * CFrame.Angles(math.random(), math.random(), math.random())
							end
						else
							LowerHealth(character.Humanoid,damage)
						end
						if changeInForce > 110 then
							Messages:send("RagdollCharacter", character, changeInForce/50)
						end
						Messages:send("PlaySound", "BoneBreak", character.Head.Position)
					end
					lastForce = 0
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
