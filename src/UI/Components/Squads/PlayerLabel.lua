local import = require(game.ReplicatedStorage.Shared.Import)

local Players = game:GetService("Players")

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })
local t = import "t"
local ReplicateToServer = import("Shared/State/Replication", { "replicateToServer" })
local Colors = import "Shared/Utils/Colors"
local SquadConstants = import "Shared/Data/SquadConstants"
local RemovePlayerFromSquad = import "Shared/Actions/Squads/RemovePlayerFromSquad"
local Padding = import "UI/Components/Padding"
local Styles = import "UI/Styles"

local clientId = tostring(Players.LocalPlayer.UserId)

local IProps = t.interface({
	squad = SquadConstants.ISquad,
	userId = t.string,
	name = t.string,
	layoutOrder = t.integer
})

local function PlayerLabel(props)
	assert(IProps(props))

	local isEven = props.layoutOrder % 2 == 0
	local isOwner = clientId == props.userId

	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1/SquadConstants.MAX_USERS, 0),
		LayoutOrder = props.layoutOrder,
		BackgroundColor3 = isEven and Colors.darken(Styles.colors.background, 5)
			or Styles.colors.background,
		BorderSizePixel = 0
	}, {
		Name = Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			Text = props.name,
			BackgroundTransparency = 1,
			TextSize = Styles.textSize,
			Font = Styles.fonts.text,
			TextColor3 = Styles.colors.text,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			Padding = Roact.createElement(Padding)
		}),

		Kick = not isOwner and Roact.createElement("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Position = UDim2.new(1, 0, 0, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Text = "X",
			TextColor3 = Styles.colors.text,
			TextSize = Styles.textSize,
			Font = Enum.Font.GothamBlack,

			[Roact.Event.Activated] = function()
				props.onKick(props.squad.id, props.userId)
			end
		})
	})
end

local function mapDispatchToProps(dispatch)
	return {
		onKick = function(squadId, userId)
			dispatch(ReplicateToServer(
				RemovePlayerFromSquad, squadId, userId
			))
		end
	}
end

return Connect(nil, mapDispatchToProps)(PlayerLabel)
