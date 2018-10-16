-- Periodic announcements and intro messages
-- A 3Ra Gaming creation
-- Modified by I_IBlackI_I
global.announcements = global.announcements or {}
global.announcements.announcement_delay = 600
-- List of announcements that are printed periodically, going through the list.
global.announcements.announcements = {
		"Check out our patreon: http://patreon.com/factoriommo",
		"Need an admin? Type @hands in chat!",
		"Check out our discord: http://discord.me/factoriommo"
}

-- List of introductory messages that players are shown upon joining (in order).
global.announcements.intros = {
	"Need an admin? Type @hands in chat!",
	"Check out our patreon: http://patreon.com/factoriommo",
	"Check out our discord: http://discord.me/factoriommo"
}
-- Go through the announcements, based on the delay set in config
-- @param event on_tick event
function announcement_show(event)
	global.announcements.last_announcement = global.announcements.last_announcement or 0
	if (game.tick / 60 - global.announcements.last_announcement > global.announcements.announcement_delay) then
		global.announcements.current_message = global.announcements.current_message or 1
		game.print(global.announcements.announcements[global.announcements.current_message])
		global.announcements.current_message = (global.announcements.current_message == #global.announcements.announcements) and 1 or global.announcements.current_message + 1
		global.announcements.last_announcement = game.tick / 60
	end
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
Event.register(defines.events.on_tick, announcement_show)
Event.register(defines.events.on_player_created, announcements_show_intro)
