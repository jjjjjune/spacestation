local import = require(game.ReplicatedStorage.Shared.Import)

local Players = game:GetService("Players")

local Roact = import "Roact"
local Styles = import "UI/Styles"
local Connect = import("RoactRodux", { "connect" })
local t = import "t"
local SquadConstants = import "Shared/Data/SquadConstants"
local Squads = import("Shared/Reducers/Squads")
local Padding = import "UI/Components/Padding"
local CreateDeleteButton = import "../CreateDeleteButton"
local InviteField = import "../InviteField"
local PlayerList = import "../PlayerList"

local clientId = tostring(Players.LocalPlayer.UserId)

local IProps = t.interface({
	squad = t.optional(SquadConstants.ISquad)
})

local function SquadManager(props)
	assert(IProps(props))

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 220, 0, 65),
		Position = UDim2.new(1, 0, 1, 0),
		AnchorPoint = Vector2.new(1, 1)
	}, {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, Styles.padding/2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		}),

		Padding = Roact.createElement(Padding, { size = Styles.padding }),

		PlayerList = props.squad and Roact.createElement(PlayerList, {
			squad = props.squad,
			layoutOrder = -3
		}),

		Invite = props.squad and Roact.createElement(InviteField, {
			squad = props.squad,
			layoutOrder = -2
		}),

		CreateDeleteButton = Roact.createElement(CreateDeleteButton, {
			squad = props.squad,
			layoutOrder = -1
		})
	})
end

local function mapStateToProps(state)
	local squad = Squads.getSquadForOwner(state, clientId)

	return {
		squad = squad
	}
end

return Connect(mapStateToProps)(SquadManager)
