local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

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
		end,
		fuelConsumption = 1, -- consumption per fuel tick
	},
	["MainPower"] = {
		init = function(model)

		end,
		on = function(model)
			for _, light in pairs(CollectionService:GetTagged("Light")) do
				light.BrickColor = BrickColor.new("White")
				light.CastShadow = false
				if light:FindFirstChild("SurfaceLight") then
					light.SurfaceLight.Enabled = true
				end
			end
			game.Lighting.Ambient = Color3.fromRGB(105,109,139)
			game.Lighting.Brightness = 2
			game.Lighting.OutdoorAmbient = Color3.fromRGB(96,73,136)
		end,
		off = function(model)
			for _, light in pairs(CollectionService:GetTagged("Light")) do
				light.BrickColor = BrickColor.new("Black")
				light.CastShadow = true
				if light:FindFirstChild("SurfaceLight") then
					light.SurfaceLight.Enabled = false
				end
			end
			game.Lighting.Ambient = Color3.fromRGB(10,10,15)
			game.Lighting.Brightness = 0
			game.Lighting.OutdoorAmbient = Color3.fromRGB(10,10,15)
		end,
		fuelConsumption = 3, -- consumption per fuel tick
	},
	["Oven"] = {
		init = function(model)
			local detector = Instance.new("ClickDetector", model.dial.Base)
			Messages:send("RegisterDetector", detector, function(player)
				Messages:send("ToggleMachine", model)
			end)
			if not model.HeatArea.HeaterSound.IsPlaying then
				model.HeatArea.HeaterSound:Play()
				model.dial.Base.BrickColor = BrickColor.new("Bright orange")
			end
			model.HeatDisplay.BrickColor = BrickColor.new("Bright orange")
			model.HeatDisplay.Fire.Rate = 40
			model.HeatArea.Temperature.Value = 1000
		end,
		on = function(model)
			if not model.HeatArea.HeaterSound.IsPlaying then
				model.HeatArea.HeaterSound:Play()
			end
			model.HeatDisplay.BrickColor = BrickColor.new("Bright orange")
			model.dial.Base.BrickColor = BrickColor.new("Bright orange")
			model.HeatDisplay.Fire.Rate = 40
			model.HeatArea.Temperature.Value = 1000
		end,
		off = function(model)
			if model.HeatArea.HeaterSound.IsPlaying then
				model.HeatArea.HeaterSound:Stop()
			end
			model.HeatDisplay.BrickColor = BrickColor.new("Sand blue")
			model.dial.Base.BrickColor = BrickColor.new("Bright blue")
			model.HeatDisplay.Fire.Rate = 0
			model.HeatArea.Temperature.Value = 0
		end,
		fuelConsumption = 1, -- consumption per fuel tick
	},
}
