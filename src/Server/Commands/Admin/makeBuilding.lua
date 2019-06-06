return {
	Name = "makeBuilding";
	Aliases = {"mb"};
	Description = "Makes a building where youre standing.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "string";
			Name = "name";
			Description = "name of building";
		},
		{
			Type = "player @ vector3";
			Name = "Position or player";
			Description = "Position to spawn the item at"
		},
	};
}
