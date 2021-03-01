GRAVEMARKER_EXPIRY_TIMER = 15 --In minutes

-- When player dies, create a map tag at their location.
function grave_marker(event)
	if not global.graves then
		global.graves = {}
	end
	local player = game.players[event.player_index]
	local force = player.force
	local tag = force.add_chart_tag(player.surface, {icon={type="item", name="power-armor"}, position=player.position, text="RIP " .. player.name})
	table.insert(global.graves, {tag, game.tick + 60 * 60 * GRAVEMARKER_EXPIRY_TIMER})
end

-- Every 15s, check the table of grave markers and remove expired ones.
function grave_expire(event)
	if not (game.tick % ( 15 * 60) == 0) then
		return
	end
	if not global.graves then
		return
	end
	for __, tag in pairs(global.graves) do
		--15 minutes
		if game.tick > tag[2] then
			if tag[1].valid then
				tag[1].destroy()
			end
			table.remove(global.graves, __)
		end
	end
end

Event.register(defines.events.on_tick, grave_expire)
Event.register(defines.events.on_player_died, grave_marker)