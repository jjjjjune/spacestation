local import = require(game.ReplicatedFirst:WaitForChild("Import"))

local Rodux = import "Rodux"
local Immutable = import "Immutable"

return Rodux.createReducer({}, {
	SetLayout = function(state, action)
		local layoutType = action.layoutType

		if layoutType ~= state.layout then
			return Immutable.set(state, "layout", layoutType)
		else
			return state
		end
	end,
	SetScale = function(state, action)
		local scale = action.scale

		return Immutable.set(state, "scale", scale)
	end,
	SetLanguage = function(state, action)
		local language = action.language

		return Immutable.set(state, "language", language)
	end,
})