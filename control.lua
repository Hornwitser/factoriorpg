--Heavy lifting stuff here.
require "mod-gui" --Klonan's button prettifier
require "utils/event" --This is so all of the modules play nice with each other.
require "utils/topgui" --Allows reordering guis.
require "utils/bot" --Discord integration
require "utils/antigrief" --Look for suspicious behavior and report it to admins/log it.
require "utils/modular_admin/modular_admin" --FMMO admin tools 
--require "utils/modular_information/modular_information" --Info windows from FMMO
--require "utils/perlin" --Perlin Noise. NOTE: If a module needs this, it'll call it.
require "modules/module_list" --Creates and displays a list of active modules on login.
require "rpg_permissions" --Limit certain actions to players level 5 or greater
require "rpg" --Award bonuses based on experience earned.
--require "permissions" --Permission manager
--require "trusted" --Module to add trusted players to a seperate permission group
--require "locale/utils/patreon" --Module to give patreons spectate and a nice unique tag
require "announcements"	--Module to announce stuff ingame / give the players a welcome message
require "modules/tag" --Module to let players set a tag behind their names to improve teamwork
--require "fmcd" --Module to consolidate saving data to an output file for the agent
--require "stats" --Module to generate stats and print them to the filesystem
--require "popup" --Module to create and display an popup in the center of all players their screens.
--require "rocket" --Module to stop people removing the rocket silo

--Modules
require "modules/gravemarker" --Mark player death locations on map for corpse runs.
require "modules/dirtpath" --For some silliness.
-- require "modules/seasons" --Let's mess with solar. --Causes desyncs until 0.17
--require "modules/dark harvest" --Only way to get uranium is from biter deaths.
--require "modules/tOredumonde" --Ore spawns in directions. This must be called before divOresity. NOTE: STONE_BYPRODUCT must be false.
--require "modules/divOresity" --Some ore gets scrambled and must be filtered.
require "modules/bluebuild" --Bluebuild softmod
require "modules/autofill" --Softmod autofill separated from Oarc
--require "modules/nougatmining" --Logistic mining softmod.
require "modules/peppermintmining" --Logistic mining softmod.
require "modules/piety" --Way to consume excess stone.
--require "belt_limit" --Limits number of belts per player.  Mostly for UPS reasons.
require "modules/bpmirror" --Adds bpmirror command to flip BPs.
require "modules/votekick" --Allows users to kick other users.
--require "modules/infinity" --Infinite ore.  Almost.  Don't recommend with peppermint/Nougat
--require "modules/enhancedbiters" --Adds extra behavior to biters to make them extra nasty.
--require "modules/lazybastard" --Much slower crafting speed
require "modules/playerlist" --List of online players
require "modules/rainbow" --Top of the line graphics!
require "modules/regional" --Regional Crafting, goods must be produced near matching region markers
--require "rpg_pocket_crafter" --Pocket crafting!
require "modules/nyan" --More silliness.

-- World Generators: Most are exclusive.
--require "maps/prospector" --Radars generate ore
--require "maps/TTSFN" --This Tank Stops for Nobody!
require "maps/dangOreus" --Ore is everywhere.  Cannot build on it!
--require "modules/divOresity" --Some ore gets scrambled and must be filtered. Must be called after dangOreus if using perlin mode.
--require "maps/searious" --Everything not a resource tile is turned into water.
--require "oarc_events" --Oarc's separate spawn scenario.
--require "maps/heximaze" --A labyrinth.
--require "maps/perlinvoid" --Organic void shapes.
--require "void" --Worldgenerator which randomly generates holes in the world
--require "nuclear" --worldgenerator for nuclear scenario
--NOT UPDATED require "grid" --Worldgenerator which devides the world into a grid.


-- FOLLOWING CODE GIVES SAME MINIMUM INVENTORY TO ALL SCENARIOS:

local function ticks_from_minutes(minutes)
	return minutes * 60 * 60
end

-- Give player starting items.
-- @param event on_player_joined event
function player_joined(event)
	local player = game.players[event.player_index]
	--if game.tick < ticks_from_minutes(10) then
		player.insert { name = "pistol", count = 1 }
		player.insert { name = "firearm-magazine", count = 20 }
		player.insert { name = "burner-mining-drill", count = 2 }
		player.insert { name = "stone-furnace", count = 2 }
	--end

	if (player.force.technologies["steel-processing"].researched) then
        player.insert { name = "steel-axe", count = 2 }
    else
        player.insert { name = "iron-axe", count = 5 }
    end
end

-- Give player weapons after they respawn.
-- @param event on_player_respawned event
function player_respawned(event)
	local player = game.players[event.player_index]

	if (player.force.technologies["military"].researched) then
        player.insert { name = "submachine-gun", count = 1 }
    else
		player.insert { name = "pistol", count = 1 }
    end

	if (player.force.technologies["uranium-ammo"].researched) then
        player.insert { name = "uranium-rounds-magazine", count = 10 }
    else 
		if (player.force.technologies["military-2"].researched) then
			player.insert { name = "piercing-rounds-magazine", count = 10 }
		else
			player.insert { name = "firearm-magazine", count = 10 }
		end
	end
end

Event.register(defines.events.on_player_created, player_joined)
Event.register(defines.events.on_player_respawned, player_respawned)

--Time for the debug code.  If any (not global.) globals are written to at this point, an error will be thrown.
--eg, x = 2 will throw an error because it's not global.x or local x
setmetatable(_G, {
	__newindex = function(_, n, v)
		log("Desync warning: attempt to write to undeclared var " .. n)
		-- game.print("Attempt to write to undeclared var " .. n)
		global[n] = v;
	end,
	__index = function(_, n)
		return global[n];
	end
})
