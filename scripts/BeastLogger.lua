
local debug_level = settings.startup["BeastFinder-DebugLevel"].value or 0
log("Log level set to " .. tostring(debug_level))

function blog(level, ...)
	-- Returns msg if level in settings is high enough (or nil otherwise)
	-- wraps each parameter in serpent.line
	-- usage:
	--   local bm = nil
	--   ...
	--   bm = blog(1, "test"); if bm then log(bm) end
	-- Above is done so log message logged with correct module & line.
	if debug_level >= level then
		local msg = ""
		local arg={...}
		for i, v in ipairs(arg) do
			if i == 2  then
				msg = msg .. " "	-- add a space between 1st paramater (expected to be function name) and first supplied variable (if any)
			elseif  i > 2 then
				msg = msg .. "▴" 	-- add separator char if more than 2 variables passed
			end
			local sl = serpent.line(v)
			-- Remove quotes added by serpent... assume that if first char is " then last is also " !! 
			if sl:sub(1,1) == '"' then sl = sl:sub(2, -2) end	
			msg = msg .. sl
			
		end
		return msg
	else
		return nil
	end
end
