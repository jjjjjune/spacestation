local import = require(game.ReplicatedStorage.Shared.Import)

local Players = game:GetService("Players")

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })
local t = import "t"
local ReplicateToServer = import("Shared/State/Replication", { "replicateToServer" })
local Padding = import "UI/Components/Padding"
local Styles = import "UI/Styles"
local Colors = import "Shared/Utils/Colors"
local CreateId = import "Shared/Utils/CreateId"
local SquadConstants = import "Shared/Data/SquadConstants"
local CreateSquad = import "Shared/Actions/Squads/CreateSquad"
local DisbandSquad = import "Shared/Actions/Squads/DisbandSquad"

local CREATE_COLOR = Color3.fromRGB(176, 255, 102)
local DISBAND_COLOR = Color3.fromRGB(255, 102, 102)

local clientId = tostring(Players.LocalPlayer.UserId)

local IProps = t.interface({
	squad = t.optional(SquadConstants.ISquad),
	onCreate = t.callback,
	onDelete = t.callback,
	layoutOrder = t.integer
})

local function CreateDeleteButton(props)
	assert(IProps(props))

	local squad = props.squad

	return Roact.createElement("TextButton", {
		Text = squad and "DISBAND SQUAD" or "NEW SQUAD",
		BackgroundColor3 = squad and DISBAND_COLOR or CREATE_COLOR,
		TextColor3 = squad and Colors.darken(DISBAND_COLOR, 75) or Colors.darken(CREATE_COLOR, 75),
		LayoutOrder = props.layoutOrder,
		Font = Styles.fonts.button,

		BorderSizePixel = 0,
		TextSize = Styles.textSize,
		Size = UDim2.new(1, 0, 1, 0),

		[Roact.Event.Activated] = function()
			if squad then
				props.onDelete(squad.id)
			else
				props.onCreate(CreateId("squad"))
			end
		end
	}, {
		Padding = Roact.createElement(Padding)
	})
end

local function mapDispatchToProps(dispatch)
	return {
		onCreate = function(squadId)
			dispatch(ReplicateToServer(CreateSquad, squadId, { clientId }))
		end,

		onDelete = function(squadId)
			dispatch(ReplicateToServer(DisbandSquad, squadId))
		end
	}
end

return Connect(nil, mapDispatchToProps)(CreateDeleteButton)
