local CollectionService = game:GetService("CollectionService")

return {
	["Air Conditioner"] = {
		init = function(model)
			print(":AC")
			model.Base.Sound:Play()
		end,
		on = function(model)
			if not model.Base.Sound.IsPlaying then
				print("play")
				model.Base.Sound:Play()
				model.Base.Debris.Enabled = true
			end
		end,
		off = function(model)
			if model.Base.Sound.IsPlaying then
				model.Base.Sound:Stop()
				model.Base.Debris.Enabled = false
			end
		end
	},
	["MainPower"] = {
		init = function(model)

		end,
		on = function(model)
			for _, light in pairs(CollectionService:GetTagged("Light")) do
				light.BrickColor = BrickColor.new("White")
				light.SurfaceLight.Enabled = true
			end
		end,
		off = function(model)
			for _, light in pairs(CollectionService:GetTagged("Light")) do
				light.BrickColor = BrickColor.new("Black")
				light.SurfaceLight.Enabled = false
			end
		end
	}
}
