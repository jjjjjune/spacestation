local import = require(game.ReplicatedStorage.Shared.Import)

local Players = game:GetService("Players")

local Roact = import "Roact"
local t = import "t"
local SquadConstants = import "Shared/Data/SquadConstants"
local PlayerLabel = import "../PlayerLabel"

local IProps = t.interface({
	layoutOrder = t.integer,
	squad = SquadConstants.ISquad
})

local function PlayerList(props)
	assert(IProps(props))

	local children = {}

	for index, userId in ipairs(props.squad.users) do
		local player = Players:GetPlayerByUserId(tonumber(userId))

		if player then
			children[userId] = Roact.createElement(PlayerLabel, {
				userId = userId,
				name = player.Name,
				squad = props.squad,
				layoutOrder = index
			})
		end
	end

	children.Layout = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	return Roact.createElement("Frame", {
		LayoutOrder = props.layoutOrder,
		BackgroundTransparency = .5,
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 3, 0),
	}, children)
end

return PlayerList
