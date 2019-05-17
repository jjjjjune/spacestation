return function (_, itemID, position)
	if typeof(position) == "Instance" then
		position = position.Character.Head.Position
	end
	local item = game.ReplicatedStorage.Assets.Items[itemID]:Clone()
	item.Parent = workspace
	item:MoveTo(position)
	return "spawned: "..itemID
end
