local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })
local t = import "t"
local PlayerStats = import "Shared/Reducers/PlayerStats"
local PlayerLabel = import "../PlayerLabel"

local IProps = t.interface({
	playerStats = PlayerStats.IPlayerStatsState
})

local function PlayerList(props)
	assert(IProps(props))

	local children = {}

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	for id, stats in pairs(props.playerStats) do
		-- TODO Sort LayoutOrder by name
		children[id] = Roact.createElement(PlayerLabel, {
			name = stats.name,
			layoutOrder = 1,
		})
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 200, 0, 24),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
	}, children)
end

local function mapStateToProps(state)
	return {
		playerStats = state.playerStats
	}
end

return Connect(mapStateToProps)(PlayerList)
