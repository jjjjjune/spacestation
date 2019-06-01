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
			game.Lighting.FogStart = 3999
		else
			game.Lighting.FogStart = 0
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
