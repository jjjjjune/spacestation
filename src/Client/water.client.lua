local import = require(game.ReplicatedStorage.Shared.Import)

local WorldConstants = import "Shared/Data/WorldConstants"
local water_level = WorldConstants.WATER_LEVEL
local player= game.Players.LocalPlayer
local swimPart = Instance.new("Part")
swimPart.Anchored = true
swimPart.Name = "swim part"
swimPart.Transparency = 1
swimPart.Size = Vector3.new(28,1,28)

local function inWater(root)
	local r = Ray.new(root.Position + Vector3.new(0,6,0), Vector3.new(0,-13,0))
	local hit, pos = workspace:FindPartOnRay(r, root.Parent)
	if hit and hit == workspace.Terrain then
		return true
	end
end

game:GetService("RunService").RenderStepped:connect(function()
    if player then
        local character = player.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                if root.Position.Y <= water_level and inWater(root) then
                    swimPart.Parent = workspace
                    swimPart.CFrame = CFrame.new(Vector3.new(root.Position.X, water_level - character.Humanoid.HipHeight - root.Size.Y/2 - 1, root.Position.Z))
                else
                    swimPart.Parent = nil
                end
            end
        end
    end
end)
