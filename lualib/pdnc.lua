-- Third itteration of programmable day-night cycle for Factorio
-- Developed by Zr4g0n with help
-- Features needed:
-- Set 'maximum brightness' from rocket launches cluster wide
-- Set 'time until doomsday' to any time, in minutes. 
-- Set 'evolution target' to any number [0.0, 1.0]
-- Changing day-night cycle based on days
-- Handle 'next time' elegantly

-- lamps enable darkness: [0.595 - 0.425] scaled to [0.0 - 0.85] range from [0.0 - 1.0] range

global.pdnc_stepsize = 21 -- also used for script.on_nth_tick
global.pdnc_surface = 1
global.pdnc_current_time = 0
global.pdnc_current_point = {x = 0, y = 1.0}
global.pdnc_last_point = {x = -1, y = 0.0}
global.pdnc_max_brightness = 1.0 -- for clusterio
global.pdnc_doomsday_start = -30.75 -- in ingame days. Negative numbers disables
global.pdnc_pollution_multiplier = 5000
global.pdnc_debug = false
global.pdnc_max_brightness_disable = false
global.pdnc_enable_rocket_darkness = true
global.pdnc_rockets_launched = 0
global.pdnc_rockets_launched_step_size = 0.025
global.pdnc_rockets_launched_smooth = 0



function pdnc_setup()
	game.surfaces[global.pdnc_surface].ticks_per_day = pdnc_min_to_ticks(10.0)
	pdnc_on_load()
end

function pdnc_on_load()
	commands.add_command("timeleft", "Gives you the time till doomsday!", pdnc_doomsday_time_left)
	if(global.pdnc_doomsday_start < 0.0) then
		pdnc_max_brightness = 0.5 -- if not doomsday, eternal night
	end
	game.print("Programmable Day-Night Cycle loaded!") 
end

function pdnc_core()
	pdnc_freeze_check()
	local s = global.pdnc_surface
	global.current_time = game.tick / game.surfaces[s].ticks_per_day
	global.pdnc_last_point = global.pdnc_current_point
	global.pdnc_current_point = {x = global.current_time, y = pdnc_program()} -- needs to be changed to use 'next point' instead to avoid aligntment issues
    local top_point = pdnc_intersection_top (global.pdnc_last_point, global.pdnc_current_point)
	local bot_point = pdnc_intersection_bot (global.pdnc_last_point, global.pdnc_current_point)
	
	-- the order is dusk - evening - morning - dawn. They *must* be in that order and they cannot be equal
	if(top_point < bot_point) then -- dusk -> evening
		pdnc_cleanup_last_tick(s)
		game.surfaces[s].evening = bot_point - global.current_time
		game.surfaces[s].dusk = top_point - global.current_time
	elseif(top_point > bot_point) then -- morning -> dawn
		pdnc_cleanup_last_tick(s)
		game.surfaces[s].morning = bot_point - global.current_time
		game.surfaces[s].dawn = top_point - global.current_time
	elseif(top_point == bot_point) then
		pdnc_debug_message("PDNC: Top and bot point equal")
		-- no cleanup here
		-- if the points are equal, use last value until not equal
		-- this should never be reached unless the pdnc_program() is broken.
	else
		pdnc_debug_message("Top and bot not different nor equal. probably a NaN error")
		pdnc_debug_message("bot_point: " .. bot_point)
		pdnc_debug_message("top_point: " .. top_point)
		-- this should never be reached.
	end
end

function pdnc_cleanup_last_tick(s)
	game.surfaces[s].daytime = 0
	-- must be in this  spesific order to 
	-- preserve the order at all times
	-- dusk < evening < morning < dawn.
	game.surfaces[s].dusk = -999999999999
	game.surfaces[s].dawn = 999999999999
	game.surfaces[s].evening = -999999999998
	game.surfaces[s].morning = 999999999998
end


function pdnc_freeze_check()
	if(game.surfaces[1].freeze_daytime)then
		game.surfaces[1].freeze_daytime = false
		game.print("Can't use freeze_daytime while programmable day-night cycle is active; time has been unfrozen")
	end
end

function pdnc_program()
	--reduce_brightness(0.5)
	local x = global.current_time * math.pi * 2
	local returnvalue = 0
	local radius = 512 --make global
	if (global.pdnc_doomsday_start < 0.0) then
		returnvalue = pdnc_c_boxy(x)
	elseif (global.current_time < global.pdnc_doomsday_start) then
		returnvalue = math.pow(pdnc_c_boxy(x), (1 + global.current_time / 4))
		-- days become shorter over time towards n^6.125
	elseif (global.current_time < global.pdnc_doomsday_start + 1) then
		global.pdnc_max_brightness_disable = true
		returnvalue = math.pow(((global.pdnc_doomsday_start + 1) - global.current_time), 7)
		pdnc_pollute(radius,returnvalue,16)
	else
		global.pdnc_max_brightness_disable = false
		returnvalue = math.pow(pdnc_c_boxy(x), 6.125)--*0.5
	end
	return pdnc_scaler(returnvalue)
end

function reduce_brightness(n)
	global.pdnc_max_brightness = 1 - ((global.current_time / global.pdnc_doomsday_start)*n)
	if(global.pdnc_max_brightness < n) then
		global.pdnc_max_brightness = n
	end
	-- 0.5 is magic number when *all* lights are on
end	

function pdnc_c_boxy(x)
	return pdnc_normalize((math.sin(x) + (0.111 * math.sin(3 * x))) * 1.124859392575928)
	-- magic numbers to make it scale to (-1, 1)
end

function pdnc_pollute(r,p,n)
	local pollution = global.pdnc_stepsize * p * global.pdnc_pollution_multiplier
	local position = {x = 0.0, y = 0.0}
	local step = (math.pi * 2) / n
	for i=0, n do
		position = {x = math.sin(step*i)*r, y = math.cos(step*i)*r}		 
		game.surfaces[global.pdnc_surface].pollute(position, pollution)
	end
end

function pdnc_normalize(n)
	return (n + 1)/2
end

function pdnc_scaler(r) -- a bit messy, but simplifies a lot elsewhere
	if(pdnc_check_valid(r, "pdnc_scaler"))then
		if(global.pdnc_max_brightness_disable) then
			return r * 0.85
		end
		
		if(pdnc_enable_rocket_darkness) then
			return r * (0.85 * global.pdnc_max_brightness * 1 -  pdnc_rocket_launch_darkness())
		end
		
		return r * (0.85 * global.pdnc_max_brightness)	
	end
end

function pdnc_intersection (s1, e1, s2, e2)
  local d = (s1.x - e1.x) * (s2.y - e2.y) - (s1.y - e1.y) * (s2.x - e2.x)
  local a = s1.x * e1.y - s1.y * e1.x
  local b = s2.x * e2.y - s2.y * e2.x
  local x = (a * (s2.x - e2.x) - (s1.x - e1.x) * b) / d
  --local y = (a * (s2.y - e2.y) - (s1.y - e1.y) * b) / d
  return x--, y
end

function pdnc_intersection_top (s2, e2)
	local s1, e1 = {x = -999999999, y = 0.85}, {x = 999999999, y = 0.85}
	return pdnc_intersection (s1, e1, s2, e2)
end

function pdnc_intersection_bot (s2, e2)
	local s1, e1 = {x = -999999999, y = 0.0}, {x = 999999999, y = 0.0}
	return pdnc_intersection (s1, e1, s2, e2)
end

function pdnc_set_max_brightness(n)
	if(pdnc_check_valid(n, "pdnc_set_max_brightness")) then
		global.pdnc_max_brightness = n
		pdnc_debug_message("global.pdnc_max_brightness set to " .. global.pdnc_max_brightness)
	end
end

function pdnc_min_to_ticks(m)
	return 60*60*m
end

function pdnc_doomsday_time_left()
	local ticks_until_doomsday = game.surfaces[global.pdnc_surface].ticks_per_day * global.pdnc_doomsday_start
	local ticks = ticks_until_doomsday - game.tick
	if (ticks >= 0) then 
		local seconds = math.floor(ticks/ 60)
		local minutes = math.floor(seconds / 60)
		local hours = math.floor(minutes / 60)
		local days = math.floor(hours / 24)
		game.print("time until doomsday: " .. string.format("%d:%02d:%02d", hours, minutes % 60, seconds % 60))
	else
		ticks = ticks * -1 
		local seconds = math.floor(ticks / 60)
		local minutes = math.floor(seconds / 60)
		local hours = math.floor(minutes / 60)
		local days = math.floor(hours / 24)
		game.print("Doomsday was: " .. string.format("%d:%02d:%02d", hours, minutes % 60, seconds % 60) .. " ago...")
	end
end

function pdnc_rocket_launch_counter()
	global.pdnc_rockets_launched = 1 + global.pdnc_rockets_launched
end

function pdnc_rocket_launch_darkness()
	if (global.pdnc_rockets_launched_smooth < global.pdnc_rockets_launched)then
		global.pdnc_rockets_launched_smooth = global.pdnc_rockets_launched_step_size + global.pdnc_rockets_launched_smooth
	end
	return (1 - (50/(global.pdnc_rockets_launched_smooth+50)))
end

function pdnc_check_valid(n, s)
	if (n == nil) then
		pdnc_debug_message(.. s .. " set to nil! Set to 1.0 instead")
		return false
	else if (n < 0)
		pdnc_debug_message(.. s .. " cannot be " .. n .. " limited to 0.0 instead")
		return false
	else if (n > 1)
		pdnc_debug_message(.. s .. " cannot be " .. n .. " limited to 1.0 instead")
		return false
	else return true
end
	
function pdnc_debug_message(s)
	if(global.pdnc_debug) then
		game.print(s)
	end
end	
	
script.on_nth_tick(global.pdnc_stepsize, pdnc_core)
script.on_init(pdnc_setup)
script.on_load(pdnc_on_load)
--script.on_rocket_launched(pdnc_rocket_launch_counter)
script.on_event(defines.events.on_rocket_launched, function(event)
  pdnc_rocket_launch_counter()
end)