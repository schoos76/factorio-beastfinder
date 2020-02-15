-------------------------------------------------------------------------------
--[[STYLES and BUTTON SPRITES]]--
-------------------------------------------------------------------------------
local style = data.raw["gui-style"].default

style.style_BeastFinder_button25 =
{
    type="button_style",
    parent="icon_button",
	minimal_height = 25,
	width = 25
}

style.style_BeastFinder_button32 =
{
    type="button_style",
    parent="icon_button",
	minimal_height = 32,
	width = 32
}

style.style_BeastFinder_button_menu =
{
    type="button_style",
    parent="icon_button",
	minimal_width = 36,
	height = 36,
}

style.style_BeastFinder_frame_filter =
{
	type="frame_style",
	parent="frame",
	vertically_stretchable = "on",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
}

style.style_BeastFinder_flow_filter =
{
    type="horizontal_flow_style",
    parent="horizontal_flow",
	align = "center",
	vertical_align = "center",
	vertically_stretchable = "on",
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
}	

style.style_BeastFinder_checkbox_product =
{
    type = "checkbox_style",
    parent="checkbox",
	checked =
	{
		filename = "__BeastFinder__/graphics/Circle16.png",
		priority = "extra-high-no-scale",
		width = 16,
		height = 16,
		scale = 0.75,
		x = 0,
		y = 0
	}
}	

style.style_BeastFinder_checkbox_ingredient =
{
    type = "checkbox_style",
    parent="checkbox",
	checked =
	{
		filename = "__BeastFinder__/graphics/Star16.png",
		priority = "extra-high-no-scale",
		width = 16,
		height = 16,
		scale = 0.75,
		x = 0,
		y = 0
	}
}	

style.style_BeastFinder_checkbox_inventory =
{
    type = "checkbox_style",
    parent="checkbox",
	checked =
	{
		filename = "__BeastFinder__/graphics/Square16.png",
		priority = "extra-high-no-scale",
		width = 16,
		height = 16,
		scale = 0.75,
		x = 0,
		y = 0
	}
}	

style.style_BeastFinder_flow_right =
{
    type="horizontal_flow_style",
    parent="horizontal_flow",
	align="right",
	horizontal_spacing = 2,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
}

style.style_BeastFinder_table = {
    type = "table_style",
    parent = "table",
    horizontal_spacing = 2,
    vertical_spacing = 2,
}

style.style_Beast_sprite_logo =
{
	type="frame_style",
	parent="frame",
	graphical_set =
	{
			filename = "__BeastFinder__/graphics/BeastFinder_Logo.png",
			priority = "high",
			width = 570,
			height = 250,
			x = 0,
			y = 0
	},
	width = 57,
	minimal_height = 25,
    top_padding = 0,
    bottom_padding = 0,
    right_padding = 0,
    left_padding = 0,
	align = "center",
}

-- Used for debugging gui layout
style.style_Beast_frame_orange =
{
	type="frame_style",
	parent="frame",
	graphical_set =
	{
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		width = 36,
		height = 36,
		x = 185,
		y = 144,
    },
    top_padding = 0,
    bottom_padding = 0,
    right_padding = 0,
    left_padding = 0,
}

style.style_Beast_frame_no_padding =
{
    type="frame_style",
    parent="frame",
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
}

style.style_Beast_table = {
    type = "table_style",
    parent = "table",
    top_padding = 2,
    bottom_padding = 0,
    right_padding = 0,
    left_padding = 0,
    cell_spacing = 0,
    horizontal_spacing = 2,
    vertical_spacing = 2,
}

style.style_Beast_textfield_short =
{
    type = "textbox_style",
    width = 50,
}

style.style_Beast_button_moo =
{
    type="button_style",
    parent="mod_gui_button",
	minimal_width = 25,
	height = 25,
    left_click_sound =
    {
        {
            filename = "__BeastFinder__/sounds/CowMoooo.ogg",
            volume = 1
        }
    },
}
