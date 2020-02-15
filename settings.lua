data:extend{
	{
		type = "bool-setting",
		name = "BeastFinder-show-toolbar",
		setting_type = "startup",
		default_value = true,
		order = "a",
	},
	{
		type = "int-setting",
		name = "BeastFinder-Rows",
		setting_type = "startup",
		default_value = "5",
		allowed_values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20},
		order = "c",
	},
	{
		type = "int-setting",
		name = "BeastFinder-Cols",
		setting_type = "startup",
		default_value = "2",
		allowed_values = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20},
		order = "d",
	},
	{
		type = "double-setting",
		name = "BeastFinder-HighlightScale",
		setting_type = "startup",
		default_value = "0.15",
		minimum_value = 0,
		maximum_value = 1.0,
		order = "e",
	},
	{
		type = "int-setting",
		name = "BeastFinder-DebugLevel",
		setting_type = "startup",
		default_value = "0",
		allowed_values = {0, 1, 2, 3, 4, 5},
		order = "f",
	},

}
