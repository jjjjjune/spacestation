return {
	Name = "setPlayerStat";
	Aliases = {"sps"};
	Description = "Sets a player stat to a value.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "player";
			Name = "Player";
			Description = "The Player";
		},
		{
			Type = "string";
			Name = "Stat name";
			Description = "The stat to edit"
		},
		{
			Type = "number @ string";
			Name = "Value";
			Description = "What to set the value to"
		},
	};
}
