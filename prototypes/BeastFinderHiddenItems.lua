local scaleFactor = settings.startup["BeastFinder-HighlightScale"].value or 0.15

local newItems = 
{
	{
		type = "item",
		name = "beastfinder-hidden-item-circle-c",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Circle.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/CircleIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-circle-cs",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Circle.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/CircleIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/SquareIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-circle-co",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Circle.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/StarIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-circle-cos",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Circle.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/SquareIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/StarIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-square-s",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Square.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/SquareIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-square-cs",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Square.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/CircleIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/SquareIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-square-os",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Square.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/SquareIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/StarIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-square-cos",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Square.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/SquareIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/CircleIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/StarIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-star-o",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Star12pink.png",
				icon_size = 256,
				scale = (scaleFactor * 1.1),	-- Star needs a bit extra to be obvious
			},
			{
				icon = "__BeastFinder__/graphics/StarIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-star-co",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Star12pink.png",
				icon_size = 256,
				scale = (scaleFactor * 1.1),	-- Star needs a bit extra to be obvious
			},
			{
				icon = "__BeastFinder__/graphics/CircleIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/StarIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-star-os",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Star12pink.png",
				icon_size = 256,
				scale = (scaleFactor * 1.1),	-- Star needs a bit extra to be obvious
			},
			{
				icon = "__BeastFinder__/graphics/SquareIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/StarIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
	{
		type = "item",
		name = "beastfinder-hidden-item-star-cos",
		
		icons = {
			{
				icon = "__BeastFinder__/graphics/Star12pink.png",
				icon_size = 256,
				scale = (scaleFactor * 1.1),	-- Star needs a bit extra to be obvious
			},
			{
				icon = "__BeastFinder__/graphics/SquareIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/CircleIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			},
			{
				icon = "__BeastFinder__/graphics/StarIcon.png",
				icon_size = 256,
				scale = scaleFactor,
			}
		},
		flags = {"hidden"},
		stack_size = 1
	},
}

data:extend(newItems)

