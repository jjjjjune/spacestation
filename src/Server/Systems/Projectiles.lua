--[[
	Messages:send("PlayAnimationClient", "Throw")
]]

local import = require(game.ReplicatedStorage.Shared.Import)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Messages = import "Shared/Utils/Messages"
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Projectile = import "Shared/Objects/Projectile"
local ProjectileFunctions = import "Shared/Data/ProjectileFunctions"
local projectilesContainer = {}

local ServerProjectiles = {}

function ServerProjectiles:start()
	RunService.Stepped:connect(function(_, dt)
		for _, projectile in pairs(projectilesContainer) do
			projectile:tick(dt)
		end
	end)
	Messages:hook("OnProjectileHit", function(projectileName, hitObject, pos, owner, direction)
		local func = ProjectileFunctions[projectileName] or ProjectileFunctions["Default"]
		if func then
			local result = func(hitObject, owner, pos, projectileName, direction)
			if not result then
				-- no result, but we handle item making in the projectile functions themselves so people cant dupe
			end
		end
	end)
	Messages:hook("CreateProjectile", function(id, pos, goal, model, ignore, owner)
		local testProjectile = Projectile.new(id)
		testProjectile:ignore(ignore)
		if owner then
			testProjectile:ignore(owner.Character)
		end
		testProjectile:spawn(pos, goal, model)
		testProjectile.model.Parent = game.ServerStorage
		testProjectile.owner = owner
		Messages:sendAllClients("CreateProjectile", id, pos, goal, model.Name)
		table.insert(projectilesContainer, testProjectile)
	end)
	Messages:hook("CreateProjectileServer", function(owner, id, pos, goal, model, ignore)
		local testProjectile = Projectile.new(id)
		testProjectile:ignore(ignore)
		if owner then
			testProjectile:ignore(owner.Character)
		end
		testProjectile:spawn(pos, goal, model)
		testProjectile.model.Parent = game.ServerStorage
		testProjectile.owner = owner
		Messages:reproOnClients(owner, "CreateProjectile", id, pos, goal, model.Name)
		table.insert(projectilesContainer, testProjectile)
	end)
	Messages:hook("RemoveProjectile", function(id, pos)
		Messages:sendAllClients("RemoveProjectile", id, pos)
		for i, projectile in pairs(projectilesContainer) do
			if projectile.id == id then
				projectile:destroy()
				projectilesContainer[i] = nil
			end
		end
	end)
end

return ServerProjectiles
