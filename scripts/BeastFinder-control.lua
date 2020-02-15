require("mod-gui")

local BeastFinder_Status = {}
local BeastFinder_Matrix = {}
local bm = nil	-- used for blog

function toolbar_init(player)
	
	bm = blog(2, "<toolbar_init()>"); if bm then log(bm) end	
	local flow = mod_gui.get_button_flow(player)
	
	if flow["beastfinder-menu-button"] then
		flow["beastfinder-menu-button"].destroy()
	end
	
	if settings["startup"]["BeastFinder-show-toolbar"] then
		if not flow["beastfinder-menu-button"] then
			local button = flow.add
			{
				type = "sprite-button",
				name = "beastfinder-menu-button",
				style = "style_BeastFinder_button_menu",	--mod_gui.button_style,
				sprite = "BeastFinder-menu-sprite",
				tooltip = {"beastfinder-menu-tooltip"}
			}
			button.visible = true
		end
	else
		bm = blog(1, "<toolbar_init()> Menu disabled in settings"); if bm then log(bm) end
	end
	
end

function glob_init(player, resetSearchItems)
	bm = blog(2, "<glob_init()>"); if bm then log(bm) end
	-- Prepares global arrays (used to save current search items etc. between loads)
	
	global["BeastFinder"] = global["BeastFinder"] or {}
	global["BeastFinder"].Layout = global["BeastFinder"].Layout or {}
	global["BeastFinder"].Layout.Rows = settings.startup["BeastFinder-Rows"].value or 5
	global["BeastFinder"].Layout.Cols = settings.startup["BeastFinder-Cols"].value or 2 	
	global["BeastFinder"].Layout.Count = global["BeastFinder"].Layout.Rows * global["BeastFinder"].Layout.Cols
	global["BeastFinder"].Version = game.active_mods["BeastFinder"].version	
	global["BeastFinder"].Displays = global["BeastFinder"].Displays or {}
	
	global["BeastFinder"].Players = global["BeastFinder"].Players or {}
	
	if player then
		bm = blog(2, "<glob_init()> player index:", player.name); if bm then log(bm) end

		global["BeastFinder"].Players[player.index] = global["BeastFinder"].Players[player.index] or {}

		local glob = global["BeastFinder"].Players[player.index]
		
		glob.range = glob.range or 2000
		glob.threshold = glob.threshold or 40
		glob.bIngredients = glob.bIngredients or false
		glob.bProducts = glob.bProducts or true
		glob.bInventory = glob.bInventory or true
		if resetSearchItems then
			glob.SearchItems = {}
		end
		glob.SearchItems = init_search_items(player)

		glob.bAutoClearAll = glob.bAutoClearAll or true
		glob.bAutoClearItem = glob.bAutoClearItem or false	
		glob.bAutoClearGUIclose = glob.bAutoClearGUIclose or false					
	else
		bm = blog(0, "<glob_init()> player is nil?"); if bm then log(bm) end
	end
	
	bm = blog(3, "<glob_init()> global['BeastFinder']:", global["BeastFinder"]); if bm then log(bm) end	
end

function init_search_items(player)	
	-- ensure the SearchItems array matches the matrix layout
	bm = blog(3, "<init_search_items()> Before SearchItems:", searchItems); if bm then log(bm) end
	
	local glob = global["BeastFinder"].Players[player.index]
	local maxIndex = global["BeastFinder"].Layout.Count
	
	local sourceSearchItems = glob.SearchItems or {}
	local targetSearchItems = {}
	
	for i = 1, maxIndex do
		targetSearchItems[i] = sourceSearchItems[i] or nil
	end
	
	bm = blog(3, "<init_search_items()> returning:", #targetSearchItems, targetSearchItems); if bm then log(bm) end
	
	return targetSearchItems

end

function close_guis(player)
	-- Close all GUIs here
	if player then
		local glob = global["BeastFinder"].Players[player.index]
		
		bm = blog(2, "<close_guis()>"); if bm then log(bm) end
		
		local flow = mod_gui.get_frame_flow(player)
		
		if flow.frame_BeastFinder_main then
			flow.frame_BeastFinder_main.destroy()
		end	
		if flow.frame_BeastFinder_settings then
			flow.frame_BeastFinder_settings.destroy()
		end
		
		if glob.bAutoClearGUIclose then
			ClearTags(player)
		end
	end
end

function gui_init(player)

	bm = blog(2, "<gui_init()>"); if bm then log(bm) end
	
	-- Close GUI on load (in case it was open during game save)
	close_guis(player)

end

function ToggleSearchGui(player)
	
	-- Close (destroy) GUI if it's open... otherwise create & display it.
	local glob = global["BeastFinder"].Players[player.index]
	bm = blog(2, "<ToggleSearchGui(" .. player.name .. ")>"); if bm then log(bm) end

	local flow = mod_gui.get_frame_flow(player)
	if flow.frame_BeastFinder_main then
        close_guis(player)
	else
		bm = blog(2, "<ToggleSearchGui()> creating gui"); if bm then log(bm) end
		
		BeastFinder_Matrix = {}
		local searchItems = glob.SearchItems
		
		local iRowsMax = global["BeastFinder"].Layout.Rows
		local iColsMax = global["BeastFinder"].Layout.Cols		
		local indexMax = global["BeastFinder"].Layout.Count		
		
		local frame_main = flow.add{type = "frame", name = "frame_BeastFinder_main", direction = "vertical",
			style = "style_Beast_frame_no_padding" }
		
		local table_main = frame_main.add{type = "table", name = "table_BeastFinder_main",
			column_count = iColsMax, style = "style_BeastFinder_table" }	--, draw_vertical_lines = true, draw_horizontal_lines = true }
		table_main.style.column_alignments[iColsMax] = "right"
		
		-- Show BeastFinder logo in top left if more than one column
		if iColsMax > 1 then
			local bfIcon = table_main.add{ type = "frame", name = "sprite_BeastFinder_logo",
				style = "style_Beast_sprite_logo", tooltip = {"BeastFinder-icon-tooltip"} }		
		end
		
		-- Dummy middle columns (if any)
		if iColsMax > 2 then
			for i = 1, (iColsMax - 2) do
				table_main.add{ type = "label", name = "label_BeastFinder_dummy_top_" .. i, caption = " " }
			end
		end

		-- Right column = clear & close X buttons
		local top_button_flow = table_main.add{ type = "flow", name = "flow_BeastFinder_top_buttons", style = "style_BeastFinder_flow_right", direction = "horizontal" }
		
		top_button_flow.add{ type = "sprite-button", name = "button_BeastFinder_ClearItems", style = "style_BeastFinder_button25",
			sprite = "utility/remove", tooltip = {"BeastFinder-clear-items-tooltip"} }
		top_button_flow.add{ type = "sprite-button", name = "button_BeastFinder_Close", style = "style_BeastFinder_button25",
			sprite = "BeastFinder-close-gui-sprite", tooltip = {"BeastFinder-close-gui-tooltip"} }

		-- Main array of search buttons
		bm = blog(2, "<ToggleSearchGui()> creating search matrix " .. iRowsMax .. " x " .. iColsMax); if bm then log(bm) end
		bm = blog(3, "<ToggleSearchGui()> searchItems:", searchItems); if bm then log(bm) end
		
		for ind = 1, indexMax do
			local table_submatrix = {}
			table_submatrix = table_main.add{type = "table", name = "table_BeastFinder_submatrix" .. ind, column_count = 2}		
			table_submatrix.style.horizontal_spacing = 0; table_main.style.vertical_spacing = 2;
			
			-- Save elem buttons to table so we can clear them easily later
			BeastFinder_Matrix[#BeastFinder_Matrix+1] = table_submatrix.add{ type = "choose-elem-button", name = "elemButton_BeastFinder_searchMatrix_" .. ind,
				elem_type = "signal", signal = searchItems[ind] }
				
			table_submatrix.add{ type = "sprite-button", name = "spriteButton_BeastFinder_searchMatrix_".. ind,
				style = "style_BeastFinder_button32", sprite = "BeastFinder-search-sprite" }			
		end
			
		-- Filters: Ingredient
		local chkframeIng = table_main.add{type = "frame", name = "frame_BeastFinder_ingredients", direction = "horizontal",
			style = "style_BeastFinder_frame_filter" }
		local chkframeIng_flow = chkframeIng.add{ type = "flow", name = "flow_BeastFinder_ingredients", direction = "horizontal",
			style = "style_BeastFinder_flow_filter" }
			
		chkframeIng_flow.add{ type = "sprite", name = "sprite_BeastFinder_ingredients",
			sprite = "BeastFinder-ingredients-sprite", tooltip = {"BeastFinder-ingredients-tooltip"} }

		chkframeIng_flow.add{ type = "checkbox", name = "checkbox_BeastFinder_ingredients", 
			tooltip = {"BeastFinder-ingredients-tooltip"}, state = glob.bIngredients,
			style = "style_BeastFinder_checkbox_ingredient" }
		
		-- does alignment need to happen after children are added??
		chkframeIng_flow.style.horizontal_align = "center"
		chkframeIng_flow.style.vertical_align = "center"
		
		-- Dummy middle columns (if any)
		if iColsMax > 2 then
			for i = 1, (iColsMax - 2) do
				table_main.add{ type = "label", name = "label_BeastFinder_dummy_ingredients_" .. i, caption = " " }
			end
		end
		
		-- Search All
		table_main.add{ type = "sprite-button", name = "button_BeastFinder_search_all", style = "style_BeastFinder_button32",
			sprite = "BeastFinder-search-all-sprite", tooltip = {"BeastFinder-search-all-tooltip"} }		

		-- Filters: Product
		local chkframePrd = table_main.add{type = "frame", name = "frame_BeastFinder_products", direction = "horizontal",
			style = "style_BeastFinder_frame_filter" }

		local chkframePrd_flow = chkframePrd.add{ type = "flow", name = "flow_BeastFinder_products", direction = "horizontal",
			style = "style_BeastFinder_flow_filter" }
			
		chkframePrd_flow.add{ type = "sprite", name = "sprite_BeastFinder_products",
			sprite = "BeastFinder-products-sprite", tooltip = {"BeastFinder-products-tooltip"} }

		local chkPrd = chkframePrd_flow.add{ type = "checkbox", name = "checkbox_BeastFinder_products",
			tooltip = {"BeastFinder-products-tooltip"}, state = glob.bProducts,
			style = "style_BeastFinder_checkbox_product" }
			
		chkframePrd_flow.style.horizontal_align = "center"
		chkframePrd_flow.style.vertical_align = "center"
		
		-- Dummy middle columns (if any)
		if iColsMax > 2 then
			for i = 1, (iColsMax - 2) do
				table_main.add{ type = "label", name = "label_BeastFinder_dummy_products_" .. i, caption = " " }
			end
		end
		
		-- Clear tags button
		table_main.add{ type = "sprite-button", name = "button_BeastFinder_ClearTags", style = "style_BeastFinder_button32",
			sprite = "BeastFinder-clear-tags-sprite", tooltip = {"BeastFinder-clear-tags-tooltip"} }		
		
		-- Filters: Container	
		local chkframeInv = table_main.add{type = "frame", name = "frame_BeastFinder_inventory", direction = "horizontal",
			style = "style_BeastFinder_frame_filter" }

		local chkframeInv_flow = chkframeInv.add{ type = "flow", name = "flow_BeastFinder_inventory", direction = "horizontal",
			style = "style_BeastFinder_flow_filter" }
			
		chkframeInv_flow.add{ type = "sprite", name = "sprite_BeastFinder_inventory",
			sprite = "BeastFinder-inventory-sprite", tooltip = {"BeastFinder-inventory-tooltip"} }

		chkframeInv_flow.add{ type = "checkbox", name = "checkbox_BeastFinder_inventory",
			tooltip = {"BeastFinder-inventory-tooltip"}, state = glob.bInventory,
			style = "style_BeastFinder_checkbox_inventory" }
			
		chkframeInv_flow.style.horizontal_align = "center"
		chkframeInv_flow.style.vertical_align = "center"
		
		-- Dummy middle columns (if any)
		if iColsMax > 2 then
			for i = 1, (iColsMax - 2) do
				table_main.add{ type = "label", name = "label_BeastFinder_dummy_inventory_" .. i, caption = " " }
			end
		end	
		
		-- Settings button
		table_main.add{ type = "sprite-button", name = "button_BeastFinder_Settings", style = "style_BeastFinder_button32",
			sprite = "BeastFinder-settings-sprite", tooltip = {"BeastFinder-settings-tooltip"} }
		
		-- Status bar (NB: outside of table_main)
		BeastFinder_Status = frame_main.add{type = "label", name = "label_BeastFinder_status",
			caption = {"BeastFinder-status-moo"}, tooltip={"BeastFinder-status-tooltip"} }		
		BeastFinder_Status.style.width = iColsMax * (25 + 32)
    
	end
end

function ToggleSettingsGui(player)
	-- Called from settings button on main Gui
	
	local glob = global["BeastFinder"].Players[player.index]
	
	bm = blog(2, "<ToggleSettingsGui()>"); if bm then log(bm) end
	
	local prog, flow
	flow = mod_gui.get_frame_flow(player)

	if flow.frame_BeastFinder_settings then
        flow.frame_BeastFinder_settings.destroy()
	else

		flow = mod_gui.get_frame_flow(player)
		
		local frame_settings = flow.add{type = "frame", name = "frame_BeastFinder_settings", direction = "vertical" }
		
		local table_main = frame_settings.add{type = "table", name = "tab_BeastFinder_settings", column_count = 2, style = "style_Beast_table"}			
		table_main.style.horizontally_stretchable = true	
		table_main.style.column_alignments[2] = "right"
		
		-- Title → BeastFinder logo 		
		local logo_flow = table_main.add{ type = "flow", name = "flow_BeastFinder_logo_settings", direction = "horizontal" }		
		logo_flow.add{ type = "frame", name = "sprite_BeastFinder_logo_settings",
			style = "style_Beast_sprite_logo", tooltip = {"BeastFinder-icon-tooltip"} }
		-- Title → "Settings" label
		logo_flow.add{type = "label", name = "label_BeastFinder_Settings_Title", caption = {"BeastFinder-Settings-caption"} }
		
		-- Title → Close icon
		table_main.add{ type = "sprite-button", name = "button_BeastFinder_Settings_close", style = "style_BeastFinder_button25",
			sprite = "BeastFinder-close-gui-sprite", tooltip = {"BeastFinder-close-gui-tooltip"} }
		
		-- Range
		table_main.add{type = "label", name = "label_Range", caption = {"BeastFinder-Range-caption"}, 
			tooltip = {"BeastFinder-Range-tooltip"}  }
		table_main.add{type = "textfield", name = "text_BeastFinder_Range", text = glob.range,
			tooltip = {"BeastFinder-Range-tooltip"}, style = "style_Beast_textfield_short", word_wrap = true}
		
		-- Threshold
		table_main.add{type = "label", name = "label_Threshold", caption = {"BeastFinder-Threshold-caption"},
			tooltip = {"BeastFinder-Threshold-tooltip"} }
		table_main.add{type = "textfield", name = "text_BeastFinder_Threshold", text = glob.threshold,
			tooltip = {"BeastFinder-Threshold-tooltip"}, style = "style_Beast_textfield_short", word_wrap = true}
	
		-- Auto clear settings
		local table_chk = frame_settings.add{type = "table", name = "tab_BeastFinder_settings_chk", column_count = 1, style = "style_Beast_table"}
		
		table_chk.add{ type = "checkbox", name = "checkbox_BeastFinder_AutoClear_All", caption = {"BeastFinder-autoclear-all-caption"},
			tooltip = {"BeastFinder-autoclear-all-tooltip"}, state = glob.bAutoClearAll }		
		table_chk.add{ type = "checkbox", name = "checkbox_BeastFinder_AutoClear_Item", caption = {"BeastFinder-autoclear-item-caption"},
			tooltip = {"BeastFinder-autoclear-item-tooltip"}, state = glob.bAutoClearItem }
		table_chk.add{ type = "checkbox", name = "checkbox_BeastFinder_AutoClear_GUIclose", caption = {"BeastFinder-autoclear-GUIclose-caption"},
			tooltip = {"BeastFinder-autoclear-GUIclose-tooltip"}, state = glob.bAutoClearGUIclose }	
			
		-- Highlight size
		local table_drop = frame_settings.add{type = "table", name = "tab_BeastFinder_settings_drop", column_count = 2, style = "style_Beast_table"}		
		
		-- Zap (force cleanup) button	
		table_drop.add{type = "label", name = "label_zap", caption = {"BeastFinder-settings-zap-caption"} }
		table_drop.add{ type = "sprite-button", name = "button_BeastFinder_Settings_zap", style = "style_Beast_button_moo",
		sprite = "BeastFinder-settings-zap-sprite", tooltip = {"BeastFinder-settings-zap-tooltip"} }
		
		-- Tip to find other settings
		-- Button just for tooltip at this stage (since no way to open Factorio options dialog from lua yet)
		table_drop.add{type = "label", name = "label_more_options", caption = {"BeastFinder-settings-more-options-caption"} }
		table_drop.add{ type = "sprite-button", name = "button_BeastFinder_Settings_more_options", style = "style_BeastFinder_button25",
			sprite = "BeastFinder-settings-more-options-sprite", tooltip = {"BeastFinder-settings-more-options-tooltip"} }
			
	end

end

function CheckNeighbors(matchResult, threshold)
		
	local ent = matchResult.entity
	local dsps = global["BeastFinder"].Displays or {}
	
	bm = blog(2, "<CheckNeighbors()> MatchedItem/threshold:", matchResult.MatchedItem, threshold); if bm then log(bm) end
	bm = blog(4, "<CheckNeighbors()> matchResult:", matchResult); if bm then log(bm) end	
	
	-- Used after matches found to group results together on map
    -- returns 0 if no close neighbors (so create new dsp)
	-- otherwise returns dsp index for first too close neighbor (so redraw dsp if required)
	
	local pos = ent.position
	local tooClose = 0
	bm = blog(2, "<CheckNeighbors()> entity pos: ", ent.position); if bm then log(bm) end
	
	if dsps ~= nil then 
		for i = 1,#dsps do		
			bm = blog(3, "<CheckNeighbors()> dsps[" .. i .. "]", dsps[i].MatchedItem.name); if bm then log(bm) end
			-- Only check if dsp if it matches MatchedItem
			if dsps[i].MatchedItem.name == matchResult.MatchedItem.name then
				bm = blog(2, "<CheckNeighbors()> checking tag '" .. dsps[i].MatchedItem.name .. "' pos: ", dsps[i].Entity.position); if bm then log(bm) end
				if (dsps[i].Entity.position.x > (pos.x - threshold)) and (dsps[i].Entity.position.x < (pos.x + threshold)) then
					if (dsps[i].Entity.position.y > (pos.y - threshold)) and (dsps[i].Entity.position.y < (pos.y + threshold)) then
						bm = blog(2, "<CheckNeighbors()> Too close!"); if bm then log(bm) end
						tooClose = i
						break
					end
				end
			else
				bm = blog(3, "<CheckNeighbors()> skipping dsp " .. dsps[i].MatchedItem.name .. " (not MatchedItem)"); if bm then log(bm) end							
			end
		end
	end
	
	bm = blog(2, "<CheckNeighbors()> returning", tooClose); if bm then log(bm) end
	return tooClose

end

function newResult()
	return {
		-- *** Result blob
		entity = {},
		MatchedItem = {},
		MatchTypes = {
			IsIngredient = false,
			IsProduct = false,
			IsInventory = false
		}
	}
end

function newDisplay()
	return {
		-- *** Display blob
		Entity = {},
		MatchedItem = {},
		MatchTypeCounts = {
			Ingredients = 0,
			Products = 0,
			Inventory = 0
		},
		HighlightTag = {},
		ItemTag = {},
		IsDirty = true
	}
end

function checkRecipe(rcp, itms, RecipeFilter)
	-- Compare recipe products &/or ingredients against items we are searching for
	-- returns Result object for each match	
	
	local results = {}
	local Result = {}
	local matchesFound = 0	
		
	if rcp ~= nil then	
		bm = blog(2, "<checkRecipe()> recipe:", rcp.name); if bm then log(bm) end
		
		if itms ~= {} then	
			if RecipeFilter.Products then
				for j, prd in pairs(rcp.products) do
					--bm = blog(3, "<checkRecipe()> checking product " .. j .. ":", prd.name); if bm then log(bm) end
					if itms[prd.name] ~= nil then		-- Checking if prd is in our itms list
						bm = blog(2, "<checkRecipe()> Product Match! ", prd.name); if bm then log(bm) end
						Result = newResult()
						Result.MatchTypes.IsProduct = true
						Result.MatchedItem = { type = prd.type, name = prd.name }
						results[#results+1] = Result
						matchesFound = matchesFound + 1
					end
				end
			end
			if RecipeFilter.Ingredients then
				--bm = blog(3, "<checkRecipe()> checking ingredients"); if bm then log(bm) end
				for k, ing in pairs(rcp.ingredients) do
					--bm = blog(3, "<checkRecipe()> checking ingredient " .. k .. ":", ing.name); if bm then log(bm) end
					if itms[ing.name] ~= nil then
						bm = blog(2, "<checkRecipe()> Ingredient Match!", ing.name); if bm then log(bm) end
						Result = newResult()
						Result.MatchTypes.IsIngredient = true
						Result.MatchedItem = { type = ing.type, name = ing.name }
						results[#results+1] = Result						
						matchesFound = matchesFound + 1
					end
				end					
			end
		end
	else
		bm = blog(2, "<checkRecipe()> recipe is nil?"); if bm then log(bm) end
	end
	
	bm = blog(4, "<checkRecipe()> returning count: ", matchesFound); if bm then log(bm) end
	
	if matchesFound == 0 then
		return nil
	else
		return results
	end
end

function checkInventory(inv, itms)
	-- Compare chest inventory against items we are searching for
	-- returns Result object	

	local Result = {}
	local results = {}
	local matchesFound = 0	
	
	if inv ~= nil then	
		bm = blog(2, "<checkInventory()> ", inv.entity_owner.name); if bm then log(bm) end

		contents = inv.get_contents()
		bm = blog(4, "<checkInventory()> contents = ", contents); if bm then log(bm) end
		for itm, j in pairs(itms) do
			--bm = blog(3, "<checkInventory()>", j, itm); if bm then log(bm) end
			if contents[itm] ~= nil then
				bm = blog(2, "<checkInventory()> Inventory Match!", itm); if bm then log(bm) end
				
				Result = newResult()
				Result.MatchTypes.IsInventory = true
				Result.MatchedItem = { type = "item", name = itm }
				results[#results+1] = Result						
				matchesFound = matchesFound + 1
			end
		end
	else
		bm = blog(2, "<checkInventory()> Inventory is nil?"); if bm then log(bm) end
	end
		
	bm = blog(4, "<checkInventory()> Matches found: ", matchesFound); if bm then log(bm) end
	
	if matchesFound == 0 then
		return nil
	else
		return results
	end
end

function checkFluidBoxes(boxes, itms)
	-- Compare storage-tank fluidboxes against items we are searching for
	-- returns table source(ingredient/product/inventory), name, type (fluid/item)

	local Result = {}	
	local results = {}
	local matchesFound = 0
	
	if boxes ~= nil then	
		bm = blog(2, "<checkFluidBoxes()>", boxes.owner.name); if bm then log(bm) end

		for itm, j in pairs(itms) do
			bm = blog(4, "<checkFluidBoxes()>", j, itm); if bm then log(bm) end
			for k = 1,#boxes do
				if boxes[k] ~= nil then
					bm = blog(3, "<checkFluidBoxes()> box " .. k .. " fluid=", boxes[k].name); if bm then log(bm) end
					if boxes[k].name == itm then						
						bm = blog(2, "<checkFluidBoxes()> FluidBox Match!", itm); if bm then log(bm) end	
						
						Result = newResult()
						Result.MatchTypes.IsInventory = true
						Result.MatchedItem = { type = "fluid", name = itm }
						results[#results+1] = Result						
						matchesFound = matchesFound + 1
					end
				else
					bm = blog(3, "<checkFluidBoxes()> box " .. k .. " fluid=nil"); if bm then log(bm) end
				end
			end
		end
	else
		bm = blog(2, "<checkFluidBoxes()> (Fluid)Boxes is nil?"); if bm then log(bm) end
	end
	
	bm = blog(4, "<checkFluidBoxes()> matchesFound: ", matchesFound); if bm then log(bm) end
	
	if matchesFound == 0 then
		return nil
	else
		return results
	end
end

function get_player_box(player)
	-- Uses the configured Range to return the search area box
	
	local glob = global["BeastFinder"].Players[player.index]
	
	bm = blog(2, "<get-player_box()>"); if bm then log(bm) end

	local range_offset = (glob.range) / 2	
	local box = {{player.position.x - range_offset, player.position.y - range_offset}, {player.position.x + range_offset, player.position.y + range_offset}}
	bm = blog(3, "<get-player_box()> = ", box); if bm then log(bm) end
	return box	
end

function GetCombinedIcon(dsp)
	-- Figure out which icon (hidden) signal to use
	
	bm = blog(2, "<GetCombinedIcon()>", dsp); if bm then log(bm) end
	
	local highest = dsp.MatchTypeCounts.Products
	local sigName = "beastfinder-hidden-item-circle-"
	
	if dsp.MatchTypeCounts.Ingredients > highest then
		highest = dsp.MatchTypeCounts.Ingredients
		sigName = "beastfinder-hidden-item-star-"
	end
	
	if dsp.MatchTypeCounts.Inventory > highest then 
		sigName = "beastfinder-hidden-item-square-"
	end

	if dsp.MatchTypeCounts.Products > 0 then
		sigName = sigName .. "c"
	end
	
	if dsp.MatchTypeCounts.Ingredients > 0 then
		sigName = sigName .. "o"
	end
	
	if dsp.MatchTypeCounts.Inventory > 0 then
		sigName = sigName .. "s"
	end
	
	return sigName
	
end

function DoSearch(event, searchIndex)
	-- Search for item at specified searchIndex (or all Items if provided)
	
	local player = game.players[event.player_index]
	local glob = global["BeastFinder"].Players[player.index]
	
	local dsps = global["BeastFinder"].Displays or {}

	bm = blog(4, "<DoSearch()> ssssssssssssssssssss"); if bm then log(bm) end
	bm = blog(2, "<DoSearch()> searchIndex:", searchIndex); if bm then log(bm) end
	
	local player = game.players[event.player_index]
		
	local rslts = FindMatches(player, searchIndex)
	
	local numGroups = ProcResults(rslts, glob.threshold)
	
	DisplayResults(player)
	
	-- Done. Update status bar.
	-- NB: Weird chars here appear as smiley face and circle icon in game
	local msg = serpent.line(#rslts)
	msg = msg .. " 😄"
	
	bm = blog(3, "<ProcResults()> # matchResults:", #rslts); if bm then log(bm) end
	bm = blog(3, "<ProcResults()> # dsps:", #dsps); if bm then log(bm) end
	
	if (#rslts > 0) and (#rslts > (numGroups)) then
		msg = msg .. " " .. (numGroups) .. " ⨀"
	end
	BeastFinder_Status.caption = msg
	bm = blog(2, "<ProcResults()> Done. Status =", msg); if bm then log(bm) end

end

function FindMatches(player, searchIndex)
	-- searches specified area for assembling machines, chests etc. then processes their recipes/contents to find the items required
	-- search for item at specified searchIndex (or all Items if provided)
	
	local glob = global["BeastFinder"].Players[player.index]

	bm = blog(2, "<FindMatches()> searchIndex:", searchIndex); if bm then log(bm) end
		
	local v = tonumber(glob.range)
	if v == nil or v <= 0 then
		BeastFinder_Status.caption = {"BeastFinder-error-bad-range"}
		return
	end

	local v = tonumber(glob.threshold)
	if v == nil or v <= 0 then
		BeastFinder_Status.caption = {"BeastFinder-error-bad-threshold"}
		return
	end
	
	local box = get_player_box(player)
	
	local ents
	local matchResults = {}
	
	-- first get target item names as key in table for quick comparison
	local SrchItms = {}
	local itms = glob.SearchItems
	
	bm = blog(3, "<FindMatches() global.BeastFinder.SearchItems:", itms); if bm then log(bm) end
	
	local searchItemCount = 0
	
	local startIndex = searchIndex or 1
	local endIndex = searchIndex or global["BeastFinder"].Layout.Count
	
	bm = blog(3, "<FindMatches()> Start/end index:", startIndex, endIndex); if bm then log(bm) end
	for i = startIndex, endIndex do		
		if itms[i] then
			bm = blog(4, "<FindMatches()> SearchItem[" .. i .. "]:", itms[i].name); if bm then log(bm) end
			SrchItms[itms[i].name] = itms[i].type
			searchItemCount = searchItemCount + 1
		else
			bm = blog(4, "<FindMatches()> SearchItem[" .. i .. "]:", nil); if bm then log(bm) end
		end
	end
	bm = blog(3, "<FindMatches()> SrchItms:", SrchItms); if bm then log(bm) end
	
	if searchItemCount == 0 then
		bm = blog(1, "<FindMatches()> No search items selected?"); if bm then log(bm) end
		if mod_gui.get_frame_flow(player).frame_BeastFinder_main then
			BeastFinder_Status.caption = {"BeastFinder-error-no-search-items"}
		end
	else
		local RecipeFilter = {
			Products = glob.bProducts,
			Ingredients = glob.bIngredients,
		}
			
		-- Find all *assembling-machines* in area then check their recipes to see if they match
		bm = blog(2, "<FindMatches()> >>>assembling-machines"); if bm then log(bm) end
		ents = player.surface.find_entities_filtered{area = box, type = "assembling-machine", force = "player"}
		for j, ent in pairs(ents) do
			bm = blog(3, "<FindMatches()> assembling-machine:", ent.name, ent.position); if bm then log(bm) end
			--log(serpent.line(ent.name) .. "@" .. serpent.line(ent.position) .. " = " .. serpent.line(ent.recipe.name))
			local results = checkRecipe(ent.get_recipe(), SrchItms, RecipeFilter)
			if results ~= nil then
				for _, result in ipairs(results) do
					result.entity = ent
					matchResults[#matchResults+1] = result
				end
			end
		end
		bm = blog(3, "<FindMatches()> matchResults so far = " .. #matchResults); if bm then log(bm) end
		
		-- Find all *furnaces* in area then check their recipes to see if they match
		bm = blog(2, "<FindMatches()> >>>furnaces"); if bm then log(bm) end
		ents = player.surface.find_entities_filtered{area = box, type = "furnace", force = "player"}
		for j, ent in pairs(ents) do
			bm = blog(3, "<FindMatches()> furnace:", ent.name, ent.position); if bm then log(bm) end
			local results = checkRecipe(ent.previous_recipe, SrchItms, RecipeFilter)
			if results ~= nil then
				for _, result in ipairs(results) do
					result.entity = ent
					matchResults[#matchResults+1] = result
				end
			end
		end
		bm = blog(3, "<FindMatches()> matchResults so far = " .. #matchResults); if bm then log(bm) end
		
		-- Find all *containers* in area then check their recipes to see if they match
		if glob.bInventory then
			bm = blog(2, "<FindMatches()> >>>containers"); if bm then log(bm) end
			ents = player.surface.find_entities_filtered{area = box, type = "container", force = "player"}
			for j, ent in pairs(ents) do
				bm = blog(3, "<FindMatches()> container:", ent.name, ent.position); if bm then log(bm) end
				local results = checkInventory(ent.get_inventory(defines.inventory.chest), SrchItms)
				if results ~= nil then
					for _, result in ipairs(results) do	
						result.entity = ent
						matchResults[#matchResults+1] = result
					end
				end
			end
			
			bm = blog(2, "<FindMatches()> logistic-containers"); if bm then log(bm) end
			ents = player.surface.find_entities_filtered{area = box, type = "logistic-container", force = "player"}
			for j, ent in pairs(ents) do
				bm = blog(3, "<FindMatches()> logistic-container:", ent.name, ent.position); if bm then log(bm) end
				local results = checkInventory(ent.get_inventory(defines.inventory.chest), SrchItms)
				if results ~= nil then
					for _, result in ipairs(results) do	
						result.entity = ent
						matchResults[#matchResults+1] = result
					end
				end
			end			

			-- Find all *storage-tanks* in area then check their recipes to see if they match
			bm = blog(2, "<FindMatches()> storage-tanks"); if bm then log(bm) end
			ents = player.surface.find_entities_filtered{area = box, type = "storage-tank", force = "player"}
			for j, ent in pairs(ents) do
				bm = blog(3, "<FindMatches()> storage-tank:", ent.name, ent.position); if bm then log(bm) end
				local results = checkFluidBoxes(ent.fluidbox, SrchItms)
				if results ~= nil then
					for _, result in ipairs(results) do	
						result.entity = ent
						matchResults[#matchResults+1] = result
					end
				end
			end				
		end

		bm = blog(2, "<FindMatches()> match!!! matchResults found:", #matchResults); if bm then log(bm) end
		
		
		bm = blog(3, "dummy")	-- Special handling for this comment for performance if large result set
		if bm then
			for i=1,#matchResults do
				if matchResults[i].entity ~= nil then
					local rt = ''
					if matchResults[i].MatchTypes.IsIngredient then rt = "(Ingredient)" end
					if matchResults[i].MatchTypes.IsProduct then rt = rt .. "(Product)" end
					if matchResults[i].MatchTypes.IsInventory then rt = rt .. "(Inventory)" end
					bm = blog(3, "<FindMatches()> matchResults " .. i .. ": "
						.. matchResults[i].entity.name, matchResults[i].MatchedItem, matchResults[i].entity.position); if bm then log(bm) end
				end
			end
		end
	end
	return matchResults
end

function ProcResults(matchResults, threshold)
	
	-- grouping
	
	local dsps = global["BeastFinder"].Displays or {}
	
	bm = blog(2, "<ProcResults()> number results:", #matchResults); if bm then log(bm) end
	bm = blog(3, "<ProcResults()> dsps A:", dsps); if bm then log(bm) end
	
	local dirtyDsps = {}
	local numDirty = 0

	if #matchResults > 0 then
		
		-- Match processing loop
		for k = 1,#matchResults do
		
			local ent = matchResults[k].entity			
			bm = blog(3, "<ProcResults()> processing match " .. k .. " = " .. ent.name); if bm then log(bm) end			
			bm = blog(4, "<ProcResults()> dsps B:", dsps); if bm then log(bm) end
						
			-- See if there are any close neighbors (based on configured Threshold)
			
			nei = CheckNeighbors(matchResults[k], threshold)
			
			bm = blog(4, "<ProcResults()> dsps C:", dsps); if bm then log(bm) end
							
			if nei == 0 then		-- No close neighbors so just add the tag
			
				bm = blog(3, "<ProcResults()> no close neighbors - create new dsp"); if bm then log(bm) end

				local newDsp = newDisplay()
				newDsp.Entity = ent
				newDsp.MatchedItem.type = matchResults[k].MatchedItem.type
				newDsp.MatchedItem.name = matchResults[k].MatchedItem.name

				if matchResults[k].MatchTypes.IsIngredient then newDsp.MatchTypeCounts.Ingredients = 1 end
				if matchResults[k].MatchTypes.IsProduct then newDsp.MatchTypeCounts.Products = 1 end
				if matchResults[k].MatchTypes.IsInventory then newDsp.MatchTypeCounts.Inventory = 1 end

				-- Add the new dsp to Displays table
				local newIndex = #dsps + 1
				dsps[newIndex] = newDsp
				dirtyDsps[newIndex] = 1
				
				bm = blog(4, "<ProcResults()> new dsp:", newIndex, newDsp); if bm then log(bm) end
				
			elseif nei > 0 then		-- Combining tag
			
				bm = blog(3, "<ProcResults()> close neighbors - combining with dsp:", nei, dsps[nei]); if bm then log(bm) end

				if matchResults[k].MatchTypes.IsIngredient then dsps[nei].MatchTypeCounts.Ingredients = dsps[nei].MatchTypeCounts.Ingredients + 1 end
				if matchResults[k].MatchTypes.IsProduct then dsps[nei].MatchTypeCounts.Products = dsps[nei].MatchTypeCounts.Products + 1 end
				if matchResults[k].MatchTypes.IsInventory then dsps[nei].MatchTypeCounts.Inventory = dsps[nei].MatchTypeCounts.Inventory + 1 end
				
				dsps[nei].IsDirty = true
				if dirtyDsps[nei] == nil then
					dirtyDsps[nei] = 1
				else
					dirtyDsps[nei] = dirtyDsps[nei] + 1		-- this count show number of matches combined with this dsp, but not used yet
				end
				bm = blog(4, "<ProcResults()> updated dsp:", nei, dsps[nei]); if bm then log(bm) end
				
			else
				bm = blog(0, "<ProcResults()> Unexpected return from CheckNeighbors = ", nei); if bm then log(bm) end
			end
			
			bm = blog(4, "<ProcResults()> dsps D:", dsps); if bm then log(bm) end
			
		end	
		
		if dirtyDsps ~= nil then
			for k, v in pairs(dirtyDsps) do
				numDirty = numDirty + 1
			end		
		end
	end
	
	return numDirty
	
end

function DisplayResults(player)
	
	local dsps = global["BeastFinder"].Displays or {}
	
	bm = blog(2, "<DisplayResults()> About to add highlight tag:", newtag); if bm then log(bm) end	
	bm = blog(3, "<DisplayResults()> dsps:", dsps); if bm then log(bm) end
	
	for k = 1, #dsps do
		local dsp = dsps[k]
		if dsp.IsDirty then
		
			if dsp.ItemTag and dsp.ItemTag.valid then
				dsp.ItemTag.destroy()
			end
			if dsp.HighlightTag and dsp.HighlightTag.valid then
				dsp.HighlightTag.destroy()
			end	
			
			-- Add the highlight tag
			newtag = {
				icon = {type = "item", name = GetCombinedIcon(dsp)},
				position = dsp.Entity.position,
				target = dsp.Entity
			}
			bm = blog(3, "<DisplayResults()> About to add highlight tag=", newtag); if bm then log(bm) end	
			dsp.HighlightTag = player.force.add_chart_tag(player.surface, newtag)

			-- Add the item tag					
			newtag.icon = dsp.MatchedItem
			bm = blog(3, "<DisplayResults()> Adding 2nd tag = ", newtag); if bm then log(bm) end					
			dsp.ItemTag = player.force.add_chart_tag(player.surface, newtag)
			
			dsp.IsDirty = false
		end

	end
end

function ClearTags(player)
		
	local dsps = global["BeastFinder"].Displays or {}

	bm = blog(3, "<ClearTags)> Displays:", dsps); if bm then log(bm) end
	local ClearCount = 0
	if dsps ~= nil then
		for k, dsp in pairs (dsps) do
			if dsp.ItemTag and dsp.ItemTag.valid then
				dsp.ItemTag.destroy()
				ClearCount = ClearCount + 1
			end
			if dsp.HighlightTag and dsp.HighlightTag.valid then
				dsp.HighlightTag.destroy()
			end		
		end
		global["BeastFinder"].Displays = {}		-- Cant use local copy
		if mod_gui.get_frame_flow(player).frame_BeastFinder_main then
			BeastFinder_Status.caption = {"BeastFinder-status-items-cleared", ClearCount, "⨀"}
		end
	end
	bm = blog(3, "<ClearTags)> Tag pairs cleared:", ClearCount); if bm then log(bm) end	
end

function ClearItems(player)
	
	local glob = global["BeastFinder"].Players[player.index]

	bm = blog(2, "<ClearItems)>"); if bm then log(bm) end
	-- Clear them from global so they dont come back!
	glob.SearchItems = {}
	
	-- Clear the items from the elem chooser
	if BeastFinder_Matrix ~= nil then
		for k=1,#BeastFinder_Matrix do
			BeastFinder_Matrix[k].elem_value = nil
		end
	else
		-- Didn't find children - probably because the GUI was open in the loaded savegame.
		-- just close the GUI instead (since global is cleared above)
		close_guis(player)
	end
	
	bm = blog(3, "<ClearItems)> Done. SearchItems:", global["BeastFinder"].Players[player.index].SearchItems); if bm then log(bm) end
end 

script.on_init(function()

	bm = blog(2, "<on_init()>"); if bm then log(bm) end
	
	global["BeastFinder"] = {}

	for k, player in pairs (game.players) do
		glob_init(player)
		toolbar_init(player)
		gui_init(player)
	end 

end)

script.on_load(function()

	-- Help to see each time save game is loaded in log
	bm = blog(1, "<on_load()> *** nothin here! *************************************"); if bm then log(bm) end

end)

script.on_configuration_changed(function(data)
	bm = blog(1, "<on_configuration_changed()>"); if bm then log(bm) end

	if not data or not data.mod_changes then
		bm = blog(1, "<on_configuration_changed()> no data"); if bm then log(bm) end
		return
	end
	
	bm = blog(3, "<on_configuration_changed()> data:" .. serpent.block(data)); if bm then log(bm) end

	if data.mod_changes["BeastFinder"] then
		bm = blog(0, "<on_configuration_changed()> BeastFinder changed."); if bm then log(bm) end
		
		local startupChanged = data.mod_startup_settings_changed
		
		close_guis(player)
		
		for k, player in pairs (game.players) do
			ClearTags(player)	-- Remove tags from map
		end		
		
		-- Clean out old configs
		if not VersionCheck(global["BeastFinder"].Version, "0.16.6") then
			bm = blog(0, "<on_configuration_changed()> Old settings detected. Resetting."); if bm then log(bm) end
			global["BeastFinder"] = {}
		end
		
		for k, player in pairs (game.players) do
			if player then
				bm = blog(1, "<on_configuration_changed()> player:", player.name); if bm then log(bm) end
			
				glob_init(player, startupChanged)		-- startupChanged to force reset of SearchItems if true
				toolbar_init(player)
				gui_init(player)
			end
		end 

	end
	
	ValidateSearchItems()

end)

function VersionCheck(version, required)
	-- Check if 'version' is at least 'required'
	if version == required then return true end
	if not version then return false end
	if not required then return true end
	
	local tv = {}
	for v in string.gmatch(version, "%d+") do
		tv[#tv+1] = v
	end
	
	local rv = {}
	for v in string.gmatch(required, "%d+") do
		rv[#rv+1] = v
	end
	
	local indexMax = math.max(#tv, #rv)
	
	local result = true
	for i = 1, indexMax do
		local tvi = tv[i] or 0
		local rvi = rv[i] or 0
	
		if tvi < rvi then
			result = false
			break
		end
	end
	
	return result
	
end

function table_length(T)
	local count = 0
	if T then
		for _ in pairs(T) do count = count + 1 end
	end
	return count
end

function ValidateSearchItems()
	bm = blog(2, "<ValidateSearchItems()>"); if bm then log(bm) end

	for k, player in pairs (game.players) do
		-- Remove any search items that no longer exist (eg: if a mod is removed)
		bm = blog(3, "<ValidateSearchItems()> Player:", k, player.name, global["BeastFinder"]); if bm then log(bm) end
		
		local items = game.item_prototypes
		local fluids = game.fluid_prototypes
		local virtuals = game.virtual_signal_prototypes
		
		local searchItems = global["BeastFinder"].Players[k].SearchItems
		
		if searchItems then
			for ind = 1, global["BeastFinder"].Layout.Count do
				local dict = {}
				
				if (table_length(searchItems[ind]) == 0) then
					searchItems[ind] = nil
				end
				
				if searchItems[ind] ~= nil then
					if searchItems[ind].type == "item" then
						dict = items
					elseif searchItems[ind].type == "fluid" then
						dict = fluids		
					elseif searchItems[ind].type == "virtual" then
						dict = virtuals
					else	
						bm = blog(0, "<ValidateSearchItems()> (Player ".. player.name .. ") Error: Unexpected signal type:", searchItems[ind]); if bm then log(bm) end
					end
					
					if dict[searchItems[ind].name] == nil then
						bm = blog(0, "<ValidateSearchItems()> (Player ".. player.name .. ") Removing invalid signal:", searchItems[ind]); if bm then log(bm) end
						searchItems[ind] = nil
					else
						bm = blog(3, "<ValidateSearchItems()> signal OK:", searchItems[ind]); if bm then log(bm) end
					end		
				end
			end
		end
	end
	
	bm = blog(2, "<ValidateSearchItems()> complete."); if bm then log(bm) end
end

script.on_event(defines.events.on_player_joined_game, function(event)
	bm = blog(2, "<on_event-on_player_joined_game()>"); if bm then log(bm) end

	local player = game.players[event.player_index] 
	glob_init(player)
	toolbar_init(player)
	gui_init(player)
end)

script.on_event(defines.events.on_gui_click, function(event) 

    local element = event.element
	local player = game.players[event.player_index]   	
	local glob = global["BeastFinder"].Players[player.index]
	
    if element.name == "beastfinder-menu-button" then
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")>"); if bm then log(bm) end
		if event.button == defines.mouse_button_type.right then
			ClearTags(player)
		else
			ToggleSearchGui(player)
		end
		
    elseif element.name == "button_BeastFinder_Settings" then
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")>"); if bm then log(bm) end
		ToggleSettingsGui(player)
		
    elseif element.name == "button_BeastFinder_Settings_zap" then
		-- This searches for tags that match the BeastFinder format and deletes them
		-- This is in contrast to the normal "clear tags" function that deletes only the tags it created.
		-- Useful if things get out of sync... typically during testing, but perhaps after a crash also?
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")>"); if bm then log(bm) end
		local box = get_player_box(player)
		local tgs = player.force.find_chart_tags(player.surface, box)
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")> found matches: ", #tgs); if bm then log(bm) end
		local zapCounter = 0
		local Tags2Del = {}
		for i, t in ipairs(tgs) do
			bm = blog(3, "<on_event-on_gui_click(" .. element.name .. ")> Tag " .. i); if bm then log(bm) end
			if t.valid then
				if t.icon == nil then 
					local logmsg = "Invalid icon for tag. Serpent: pos=" .. serpent.line(t.position) .. ", tag=" .. serpent.line(t.tag_number)
					if t.last_user ~= nil then logmsg = logmsg .. ", user=" .. t.last_user.name end
					logmsg = logmsg .. ", text=" .. serpent.line(t.text)
					if t.target ~= nil then logmsg = logmsg .. ", target=" .. t.target.name end
					
					bm = blog(3, "<on_event-on_gui_click(" .. element.name .. ")> " .. logmsg); if bm then log(bm) end
				else
					bm = blog(3, "<on_event-on_gui_click(" .. element.name .. ")> Tag valid = " .. t.icon.name); if bm then log(bm) end
					if t.icon.name:find("^beastfinder%-hidden%-item") ~= nil then		-- beastfinder-hidden-item*
						-- Match for boundry tag - see if any other tags at same location
						for i2,t2 in ipairs(tgs) do
							if t2.valid then
								if t.position.x == t2.position.x then
									if t.position.y == t2.position.y then									
										Tags2Del[#Tags2Del+1] = t2
										bm = blog(3, "<on_event-on_gui_click(" .. element.name .. ")> Tag at same location added for destroy as Tags2Del[" .. #Tags2Del .. "]"); if bm then log(bm) end
									end
								end
							end
						end
						Tags2Del[#Tags2Del+1] = t
						bm = blog(3, "<on_event-on_gui_click(" .. element.name .. ")> Added for destroy as Tags2Del[" .. #Tags2Del .. "]"); if bm then log(bm) end
					end
				end
			end
		end
		
		for i = 1,#Tags2Del do
			if Tags2Del[i].valid then
				bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")> Destroy = " .. i); if bm then log(bm) end
				Tags2Del[i].destroy()
				zapCounter = zapCounter + 1
			end
		end
		
		bm = blog(3, "<on_event-on_gui_click(" .. element.name .. ")> zapCounter =" .. zapCounter); if bm then log(bm) end
		BeastFinder_Status.caption = {"BeastFinder-status-zapped", zapCounter, "⨀"}			--tostring(zapCounter)}
				
    elseif element.name == "button_BeastFinder_ClearTags" then
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")>"); if bm then log(bm) end
		
		ClearTags(player)

    elseif element.name == "button_BeastFinder_ClearItems" then
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")>"); if bm then log(bm) end
		
		ClearItems(player)

	elseif element.name == "button_BeastFinder_search_all" then
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")>"); if bm then log(bm) end
		
		BeastFinder_Status.caption = {"BeastFinder-status-searching-all"}
		
		if glob.bAutoClearAll then
			ClearTags(player)
		end
		DoSearch(event)
	
	elseif element.name == "button_BeastFinder_Close" then
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")>"); if bm then log(bm) end
		close_guis(player)
		
	elseif element.name == "button_BeastFinder_Settings_close" then
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")>"); if bm then log(bm) end

		if mod_gui.get_frame_flow(player).frame_BeastFinder_settings then
			mod_gui.get_frame_flow(player).frame_BeastFinder_settings.destroy()
		end

	elseif element.name:find("^spriteButton_BeastFinder_searchMatrix_") ~= nil then
		bm = blog(2, "<on_event-on_gui_click(" .. element.name .. ")>"); if bm then log(bm) end		
		BeastFinder_Status.caption = {"BeastFinder-status-searching"}
				
		-- Figure out which individual search button was clicked
		index = tonumber(element.name:match("_(%d+)$"))
		bm = blog(3, "<on_event-on_gui_click(" .. element.name .. ")> Index =", index); if bm then log(bm) end	
		
		if glob.bAutoClearItem then
			ClearTags(player)
		end
		
		DoSearch(event, index, index)			
	end			
	
end)

script.on_event(defines.events.on_gui_text_changed, function(event) 

    local element = event.element
	local player = game.players[event.player_index]  
	local glob = global["BeastFinder"].Players[player.index]   
	
	if element.name == "text_BeastFinder_Range" then
		bm = blog(2, "<on_event-on_gui_text_changed(" .. element.name .. ")> =", element.text); if bm then log(bm) end
		glob.range = element.text
	elseif element.name == "text_BeastFinder_Threshold" then
		bm = blog(2, "<on_event-on_gui_text_changed(" .. element.name .. ")> =", element.text); if bm then log(bm) end
		glob.threshold = element.text
	end
 
end)

script.on_event(defines.events.on_gui_elem_changed, function(event) 

	if event.element.name:find("^elemButton_BeastFinder_searchMatrix_") ~= nil then
		local element = event.element
		local player = game.players[event.player_index]    
		local glob = global["BeastFinder"].Players[player.index]
		
		bm = blog(2, "<on_event-on_gui_elem_changed(" .. element.name .. ")>:", element.elem_value); if bm then log(bm) end
		
		index = tonumber(element.name:match("_(%d+)$"))		-- get number at end after _
		
		bm = blog(3, "<on_event-on_gui_elem_changed(" .. element.name .. ")> Index:", index); if bm then log(bm) end
				
		glob.SearchItems[index] = element.elem_value
		bm = blog(4, "<on_event-on_gui_elem_changed()> SearchItems:", glob.SearchItems); if bm then log(bm) end
	end	
	
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event) 
	
	local glob = global["BeastFinder"].Players[event.player_index]

	if event.element.name == "checkbox_BeastFinder_ingredients" then
		bm = blog(2, "<on_event-on_gui_click(" .. event.element.name .. ")>"); if bm then log(bm) end
		glob.bIngredients = event.element.state
		
	elseif event.element.name == "checkbox_BeastFinder_products" then
		bm = blog(2, "<on_event-on_gui_click(" .. event.element.name .. ")>"); if bm then log(bm) end
		glob.bProducts = event.element.state		
		
	elseif event.element.name == "checkbox_BeastFinder_inventory" then
		bm = blog(2, "<on_event-on_gui_click(" .. event.element.name .. ")>"); if bm then log(bm) end
		glob.bInventory = event.element.state		

	elseif event.element.name == "checkbox_BeastFinder_AutoClear_All" then
		bm = blog(2, "<on_event-on_gui_click(" .. event.element.name .. ")>"); if bm then log(bm) end
		glob.bAutoClearAll = event.element.state

	elseif event.element.name == "checkbox_BeastFinder_AutoClear_Item" then
		bm = blog(2, "<on_event-on_gui_click(" .. event.element.name .. ")>"); if bm then log(bm) end
		glob.bAutoClearItem = event.element.state

	elseif event.element.name == "checkbox_BeastFinder_AutoClear_GUIclose" then
		bm = blog(2, "<on_event-on_gui_click(" .. event.element.name .. ")>"); if bm then log(bm) end
		glob.bAutoClearGUIclose = event.element.state

	end
	
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event) 
	
	local glob = global["BeastFinder"].Players[event.player_index]
	
	if event.element.name == "bf666_drop_Beast_Highlights" then
		bm = blog(2, "<on_event-on_gui_dropdown(" .. event.element.name .. ")>"); if bm then log(bm) end
		glob.intHighlights = event.element.selected_index
	end
	
end)