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
	RunService.Stepped:connect(function(_, dt)
		for _, projectile in pairs(projectilesContainer) do
			projectile:tick(dt)
		end
	end)
	Messages:hook("CreateProjectile", function(id, pos, goal, modelName)
		local testProjectile = Projectile.new(id)
		testProjectile:ignore(workspace) -- remember not to do this on the server
		testProjectile:spawn(pos, goal, game.ReplicatedStorage.Assets.Items[modelName]:Clone())
		table.insert(projectilesContainer, testProjectile)
	end)
	Messages:hook("RemoveProjectile", function(id, pos)
		for i, projectile in pairs(projectilesContainer) do
			if projectile.id == id then
				projectile:destroy()
				projectilesContainer[i] = nil
			end
		end
	end)
end

return ClientProjectiles
