return {
	Name = "makeItem";
	Aliases = {"mi"};
	Description = "Creates item at a given position.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "string";
			Name = "Item ID";
			Description = "The ID of the item";
		},
		{
			Type = "player @ vector3";
			Name = "Position or player";
			Description = "Position to spawn the item at"
		},
	};
}
