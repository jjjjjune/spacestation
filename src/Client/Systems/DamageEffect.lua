local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TweenService = game:GetService("TweenService")

local DamageEffect = {}

local length = .2

function DamageEffect:start()
	Messages:hook("DoDamageEffect", function(character)
		local parts = {}
		for i, possiblePart in pairs(character:GetChildren()) do
			if possiblePart:IsA("BasePart") and possiblePart.Transparency < 1 then
				local part = possiblePart:Clone()
				part.Name = "x"
				part.Size = possiblePart.Size * 1.16
				part:BreakJoints()
				part.RootPriority = 0
				part.Massless = true
				part.Transparency = 1
				part.CanCollide = false
				part.CFrame = possiblePart.CFrame * CFrame.new(.1,0,0)
				if part:IsA("MeshPart") then
					part.TextureID = ""
				end
				if part:FindFirstChild("Mesh") then
					part.Mesh.TextureId = ""
					if part.Mesh:IsA("SpecialMesh") then
						part.Mesh.Scale = part.Mesh.Scale * 1.16
					end
				end
				for _, n in pairs(part:GetChildren()) do
					if n:IsA("Attachment") or n:IsA("Motor6D") then
						n:Destroy()
					end
				end
				part.BrickColor = BrickColor.new("Bright red")
				part.Material = Enum.Material.Neon
				part.Parent = workspace
				local w = Instance.new("WeldConstraint", part)
				w.Part0 = possiblePart
				w.Part1 = part
				table.insert(parts, part)
				game:GetService("Debris"):AddItem(part, length*2)
			end
		end
		for i, part in pairs(parts) do
			local tweenInfo = TweenInfo.new(
				length,
				Enum.EasingStyle.Bounce,
				Enum.EasingDirection.Out,
				0
			)
			local tween = TweenService:Create(part,tweenInfo, {Transparency = 0.7})
			tween:Play()
		end
		spawn(function()
			wait(length)
			for i, part in pairs(parts) do
				local tweenInfo = TweenInfo.new(
					length,
					Enum.EasingStyle.Bounce,
					Enum.EasingDirection.Out,
					0
				)
				local tween = TweenService:Create(part,tweenInfo, {Transparency = 1})
				tween:Play()
			end
		end)
	end)
end

return DamageEffect
