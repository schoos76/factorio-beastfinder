
-- *** REMOTE INTERFACES *** --

-- Keep separate remote functions for logging if nothing else
function remoteToggleSearchGui()
	if game.player then
		local name = game.player.name or "<unknown>"
		bm = blog(0, "<remoteToggleSearchGui(" .. name .. ")>"); if bm then log(bm) end	
		ToggleSearchGui(game.player)
	else
		bm = blog(0, "<remoteToggleSearchGui()> error - no game.player"); if bm then log(bm) end	
	end
end

function remoteReset()
	
	local name = "<unknown>"
	if game.player and game.player.name then
		name = game.player.name 	
	end
	
	blog(0, "<remoteReset()> requested by:", name)
	
	for k, player in pairs (game.players) do
		ClearTags(player)	-- Remove tags from map
	end

	global["BeastFinder"] = {}
		
	for k, player in pairs (game.players) do
		glob_init(player)
		toolbar_init(player)
		gui_init(player)
	end 
		
	bm = blog(0, "<remoteReset()> reset complete."); if bm then log(bm) end	
	if game.player then
		game.player.print("BeastFinder: reset complete.")
	end

end

-- Add the interfaces
remote.add_interface("BeastFinder", {ToggleSearchGui = remoteToggleSearchGui, Reset = remoteReset})

-- *** SHORTCUT EVENTS *** --
					 
script.on_event("beastfinder-hotkey-togglesearchgui", function(event)

	blog(2, "<on_event-beastfinder-hotkey-togglesearchgui(" .. event.name .. ")>")

	ToggleSearchGui(game.players[event.player_index])
	
end)					 