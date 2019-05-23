local player = game.Players.LocalPlayer

local function doLighting()
	local isInHell = false
	local character = player.Character
	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			if humanoidRootPart.Position.Y > 1400 then
				isInHell = true
			end
		end
		if isInHell then
			game.Lighting.FogColor = Color3.fromRGB(0, 0, 0)
			game.Lighting.ClockTime = 0
		else
			--[[game.Lighting.FogColor = Color3.fromRGB(151, 250, 255)
			game.Lighting.ClockTime = 12--]]
		end
	end
end

local Lighting = {}

function Lighting:start()
	spawn(function()
		while wait() do
			doLighting()
		end
	end)
end

return Lighting
