local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Knockback = {}

local knockbackStart = -1000
local KNOCKBACK_LENGTH = .2
local knockbackVelocity = 0
local player = game.Players.LocalPlayer

function Knockback:start()
	Messages:hook("Knockback", function(velocity, t )
		if t then KNOCKBACK_LENGTH = t end
		knockbackStart = tick()
		knockbackVelocity = velocity
	end)
	game:GetService("RunService").RenderStepped:connect(function()
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			if tick() - knockbackStart < KNOCKBACK_LENGTH then
				hrp.Velocity = Vector3.new(knockbackVelocity.X, hrp.Velocity.Y, knockbackVelocity.Z)
			end
		end
	end)
end

return Knockback
