local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })
local t = import "t"
local Styles = import "UI/Styles"
local PlayerStats = import "Shared/Reducers/PlayerStats"

local IProps = t.interface({
	userId = t.string,
	playerStats = PlayerStats.IPlayerStatsState
})

local function PlayerNametag(props)
	assert(IProps(props))

	local stats = props.playerStats[props.userId]

	if stats then
		return Roact.createElement("BillboardGui", {
			Size = UDim2.new(10, 0, 0.6, 0),
			StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0),
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}, {
			Label = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.Fantasy,
				Text = stats.name,
				TextColor3 = Color3.fromRGB(222, 222, 222),
				TextScaled = true,
				TextSize = Styles.textSize,
				TextStrokeColor3 = Color3.fromRGB(76, 76, 76),
				TextStrokeTransparency = 0,
			})
		})
	end
end

local function mapStateToProps(state, props)
	return {
		playerStats = state.playerStats
	}
end

return Connect(mapStateToProps)(PlayerNametag)
