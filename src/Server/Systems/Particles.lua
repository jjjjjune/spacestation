local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local ParticlesFolder = import "Assets/Particles"


local Particles ={}

function Particles:start()
	Messages:hook("PlayParticle", function(particleName, amount, position)
		local attach = Instance.new("Attachment", workspace.Terrain)
		attach.Position = position
		local particleInstance = ParticlesFolder[particleName]:Clone()
		particleInstance.Parent = attach
		particleInstance:Emit(amount)
		game:GetService("Debris"):AddItem(attach,1)
	end)
end

return Particles
