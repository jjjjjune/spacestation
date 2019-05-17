local import = require(game.ReplicatedStorage.Shared.Import)

local Players = game:GetService("Players")

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })
local t = import "t"
local ReplicateToServer = import("Shared/State/Replication", { "replicateToServer" })
local InputField = import "../InputField"
local SquadConstants = import "Shared/Data/SquadConstants"
local AddPlayerToSquad = import "Shared/Actions/Squads/AddPlayerToSquad"

local IProps = t.interface({
	squad = SquadConstants.ISquad,
	layoutOrder = t.integer,
	onInvite = t.callback
})

local function InviteField(props)
	assert(IProps(props))

	return Roact.createElement(InputField, {
		layoutOrder = props.layoutOrder,
		placeholder = "Invite player...",
		onSubmit = function(text)
			local player = Players:FindFirstChild(text)

			if player then
				local userId = tostring(player.UserId)
				props.onInvite(props.squad.id, userId)
			end
		end
	})
end

local function mapDispatchToProps(dispatch)
	return {
		onInvite = function(squadId, userId)
			dispatch(ReplicateToServer(
				AddPlayerToSquad, squadId, userId
			))
		end
	}
end

return Connect(nil, mapDispatchToProps)(InviteField)
