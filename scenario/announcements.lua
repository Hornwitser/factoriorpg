-- Periodic announcements and intro messages
-- A 3Ra Gaming creation
-- Modified by I_IBlackI_I
global.announcements = global.announcements or {}
--global.announcements.announcement_delay = 60 * 60 * 20
-- List of announcements that are printed periodically, going through the list.
global.announcements.announcements = {
	"Check out the FMMO patreon: http://patreon.com/factoriommo",
	"Need an admin? Type @hands in chat!",
	"Check out our discord: http://discord.me/factoriommo",
	"Thank you for playing FactorioRPG!",
	"Join us on the Factorio RPG discord! http://chromaticrabbit.com/factoriorpg",
	"Enjoying FactorioRPG? Support the programmer on Patreon: https://www.patreon.com/mylon",
	
}

-- List of introductory messages that players are shown upon joining (in order).
global.announcements.intros = {
	"Need an admin? Type @hands in chat!",
	"Check out our patreon: http://patreon.com/factoriommo",
	"Check out our discord: http://discord.me/factoriommo",
	"Welcome to Factorio RPG hosted by FMMO!  Earn exp by launching rockets, researching technology, or killing biter nests.  The first rocket is worth the most.",
	"Levels provide small bonuses like movement speed, bonus inventory slots, bonus health, and more.",
}
-- Go through the announcements, based on the delay set in config
-- @param event on_tick event
function announcement_show(event)
	--global.announcements.last_announcement = global.announcements.last_announcement or 0
	--if (game.tick - global.announcements.last_announcement > global.announcements.announcement_delay) then
		global.announcements.current_message = global.announcements.current_message or 1
		game.print(global.announcements.announcements[global.announcements.current_message])
		global.announcements.current_message = (global.announcements.current_message == #global.announcements.announcements) and 1 or global.announcements.current_message + 1
		--global.announcements.last_announcement = game.tick
	--end
end

-- Show introduction messages to players upon joining
-- @param event
function announcements_show_intro(event)
	local player = game.players[event.player_index]
	for i,v in pairs(global.announcements.intros) do
		player.print(v)
	end
end

-- Event handlers
return {
	on_nth_tick = { [60*60*20] = announcement_show },
	events = { [defines.events.on_player_created] = announcements_show_intro },
}
