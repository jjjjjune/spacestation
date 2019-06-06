local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local FallDamage = {}

function FallDamage:start()
	local player = game.Players.LocalPlayer
	player.CharacterAdded:connect(function(character)
		local connect
		local lastY = 0
		local lastChangeInDistance = 0
		local totalDistance = 0
		character:WaitForChild("HumanoidRootPart")
		local connect
		connect = game:GetService("RunService").RenderStepped:connect(function(deltaTime)

			if not character:FindFirstChild("HumanoidRootPart") then
				connect:disconnect()
				return
			end

			local currentY =character.HumanoidRootPart.Position.Y

			local changeInDistance = currentY - lastY

			if (lastChangeInDistance < 0 and changeInDistance > 0) and totalDistance > 1 then
				Messages:sendServer("CharacterFellDistance", totalDistance)
				totalDistance= 0
			else
				-- in the future we'll only add to this if your velocity is above a certain amount
				if changeInDistance < 0 and changeInDistance < (2000) and character.HumanoidRootPart.Velocity.Y < -40 then
					totalDistance = totalDistance + math.abs(changeInDistance)
				end
			end

			lastChangeInDistance = changeInDistance
			lastY = currentY
			if character.Parent == nil then
				connect:disconnect()
			end
		end)
	end)
end



return FallDamage
