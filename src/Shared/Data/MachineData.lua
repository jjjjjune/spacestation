return {
	["Air Conditioner"] = {
		init = function(model)
			model.Base.Sound:Play()
		end,
		on = function(model)
			if not model.Base.Sound.IsPlaying then
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
	}
}
