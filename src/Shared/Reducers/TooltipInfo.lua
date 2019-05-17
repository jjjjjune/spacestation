local import = require(game.ReplicatedStorage.Shared.Import)

local CreateReducer = import("Rodux", { "createReducer" })
local Immutable = import "Immutable"
local RemoveByKey = import "../Generic/RemoveByKey"

local exports = {}

exports.reducer = CreateReducer({}, {
	SetTooltipName = function(state, action)
		return Immutable.set(state,"tooltipName",action.tooltipName)
	end,
	SetTooltipPosition = function(state, action)
		return Immutable.set(state,"tooltipPosition",action.position)
	end,
	SetTooltipButton = function(state, action)
		return Immutable.set(state,"tooltipButton",action.button)
	end,
	SetTooltipDescription = function(state, action)
		return Immutable.set(state,"tooltipDescription",action.description)
	end,
	SetTooltipVisible = function(state, action)
		return Immutable.set(state,"tooltipVisible", action.visible)
	end,

})

return exports
