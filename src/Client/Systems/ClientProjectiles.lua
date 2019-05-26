local import = require(game.ReplicatedStorage.Shared.Import)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Messages = import "Shared/Utils/Messages"
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Projectile = import "Shared/Objects/Projectile"
local projectilesContainer = {}

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local ClientProjectiles = {}

function ClientProjectiles:start()
	mouse.KeyDown:connect(function(key)
		if key == "t" then
			Messages:sendServer("ThrowTest")
		end
	end)
	RunService.RenderStepped:connect(function(dt)
		for _, projectile in pairs(projectilesContainer) do
			projectile:tick(dt)
		end
	end)
	Messages:hook("CreateProjectile", function(id, pos, goal, model)
		--game.ReplicatedStorage.Assets.Items.Axe
		local testProjectile = Projectile.new(id)
		testProjectile:ignore(workspace) -- remember not to do this on the server
		testProjectile:spawn(pos, goal)
		table.insert(projectilesContainer, testProjectile)
	end)
	Messages:hook("RemoveProjectile", function(id, pos)
		Messages:send("PlayParticle", "Shine", 1, pos)
		Messages:send("PlaySound", "MineStone", pos)
		for i, projectile in pairs(projectilesContainer) do
			if projectile.id == id then
				projectilesContainer[i] = nil
			end
		end
	end)
end

return ClientProjectiles
