--A patreon-rewarding module build by I_IBlackI_I for FactorioMMO
--This module gives patreons the ability to have a unique tag and a general patreon tag
--  they can also use basic spectating, but not teleporting or following.


global.patreon = global.patreon or {}
global.patreon.patreons = {
		{name = "I_IBlackI_I", tag = "Lua Hero"},
		{name = "psihius", tag = "SysAdmin"},
		{name = "Hornwitser", tag = "MoneyBags"},
		{name = "jordank321", tag = "Im not sure LMAO"},
		{name = "viceroypenguin", tag = "MoneyBags"},
		{name = "sikian", tag = "Sikjizz!"},
		{name = "Lyfe", tag = "Is Alive"},
		{name = "sniperczar", tag = "Behemoth Bait"},
		{name = "i-l-i", tag = "Space Dolphin"},
		{name = "Uriopass", tag = "Ratio Maniac"},
		{name = "audigex", tag = "Spaghetti Monster"},
		{name = "Sergeant_Steve", tag = "Biter Killer"},
		{name = "Zr4g0n", tag = "Totally not a dragon!"},
		{name = "LordKiwi", tag = nil},
		{name = "stik", tag = nil},
		{name = "Zirr", tag = nil},
		{name = "Nr42", tag = nil},
		{name = "zerot", tag = nil}
	}
global.patreon.player_spectator_state = global.patreon.player_spectator_state or {}
global.patreon.player_spectator_character = global.patreon.player_spectator_character or {}
global.patreon.player_spectator_force = global.patreon.player_spectator_force or {}
global.patreon.player_spectator_logistics_slots = global.patreon.player_spectator_logistics_slots or {}


function patreon_shoutout(event)
	local player = game.players[event.player_index]
	if patreon_check(player) and player.admin == false then
		game.print("Special shout out to our Patreon " .. player.name)
	end
end

function patreon_joined(event)
	local player = game.players[event.player_index]
	if(patreon_check(player)) then
		patreon_create_patreon_top_gui(player.name)
		if(global.permissions)then
			permissions_add_player(player, "patreons")
		end
	end
end

function patreon_check(player)
	for _, patreon in pairs(global.patreon.patreons) do
		if(player.name == patreon.name) then
			return true
		end
	end
	return false
end
function patreon_create_patreon_top_gui(player_name)
	local player = game.players[player_name]
	if mod_gui.get_button_flow(player).patreon_menu == nil then
		mod_gui.get_button_flow(player).add { name = "patreon_menu", type = "button", caption = "Open Patreon" }
	end
end
function patreon_create_patreon_pane(player_name)
	local player = game.players[player_name]
	local index = player.index
	local patreon_pane = nil
	if not mod_gui.get_frame_flow(player).patreon_pane then
		patreon_pane = mod_gui.get_frame_flow(player).add { name = "patreon_pane", type = "frame", direction = "vertical", caption = "Patreon GUI " }
	else
		patreon_pane = mod_gui.get_frame_flow(player).patreon_pane
	end
	if not mod_gui.get_frame_flow(player).patreon_pane.unique_tag then
		patreon_pane.add { name = "unique_tag", type = "button", caption = "Unique Tag" }
	end
	if not mod_gui.get_frame_flow(player).patreon_pane.patreon_tag then
		patreon_pane.add { name = "patreon_tag", type = "button", caption = "Patreon Tag" }
	end
	if player.admin == false then
		if not mod_gui.get_frame_flow(player).patreon_pane.spectate then
			patreon_pane.add { name = "spectate", type = "button", caption = "Spectate" }
		end
	end
end

function patreon_gui_click(event)
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then
		if e.name == "spectate" and e.parent.name == "patreon_pane" then
			if(p.admin == false) then
				patreon_spectate_on(i)
			else
				p.print("Use the spectate in the admin tools")
			end
		elseif e.name == "return_character" and e.parent.name == "patreon_pane" then
			if(p.admin == false) then
				patreon_spectate_off(i)
			else
				p.print("Use the spectate in the admin tools")
			end
		elseif e.name == "unique_tag" and e.parent.name == "patreon_pane" then
			patreon_apply_unique_tag(p)
		elseif e.name == "patreon_tag" and e.parent.name == "patreon_pane" then
			p.print("The general patreon tag has been applied!")
			p.tag = " [Patreon]"
		elseif e.name == "patreon_menu" and e.caption == "Open Patreon" then
			patreon_create_patreon_pane(p.name)
			mod_gui.get_button_flow(p).patreon_menu.caption = "Close Patreon"
		elseif e.name == "patreon_menu" and e.caption == "Close Patreon" then
			if mod_gui.get_frame_flow(p).patreon_pane ~= nil then
				mod_gui.get_frame_flow(p).patreon_pane.destroy()
			end
			mod_gui.get_button_flow(p).patreon_menu.caption = "Open Patreon"
		end
	end
end

function patreon_apply_unique_tag(player)
	for i, patreon in pairs(global.patreon.patreons) do
		if(player.name == patreon.name) then
			if(patreon.tag ~= nil) then
				player.tag = " [" .. patreon.tag .. "]"
				player.print("Your unique tag has been applied!")
			else 
				player.print("O.o It seems you don't have a unique tag.. Please contact the admins to get one.")
			end
		end
	end
end


function patreon_spectate_off(index)
	local player = game.players[index]
	global.patreon.player_spectator_state[index] = false
	mod_gui.get_frame_flow(player).patreon_pane.return_character.destroy()
	mod_gui.get_frame_flow(player).patreon_pane.add { name = "spectate", type = "button", caption = "Spectate" }
	if player.character == nil then
		local pos = player.position
		if global.patreon.player_spectator_character[index] and global.patreon.player_spectator_character[index].valid then
			player.print("Returning you to your character.")
			player.set_controller { type = defines.controllers.character, character = global.patreon.player_spectator_character[index] }
		else
			player.print("Character missing, will create new character at spawn.")
			player.set_controller { type = defines.controllers.character, character = player.surface.create_entity { name = "player", position = { 0, 0 }, force = global.patreon.player_spectator_force[index] } }
			player.insert { name = "pistol", count = 1 }
			player.insert { name = "firearm-magazine", count = 10 }
		end
		--restore character logistics slots due to bug in base game that clears them after returning from spectator mode
		for slot=1, player.character.request_slot_count do
			if global.patreon.player_spectator_logistics_slots[index][slot] then
				player.character.set_request_slot(global.player_spectator_logistics_slots[index][slot], slot)
			end
		end
	end
	player.force = game.forces[global.patreon.player_spectator_force[index].name]
end

function patreon_spectate_on(index)
	local player = game.players[index]
	global.patreon.player_spectator_state[index] = true
	mod_gui.get_frame_flow(player).patreon_pane.spectate.destroy()
	mod_gui.get_frame_flow(player).patreon_pane.add { name = "return_character", type = "button", caption = "Stop Spectating" }
	if player.character then
		player.character.destructible = false
		player.walking_state = { walking = false, direction = defines.direction.north }
		global.patreon.player_spectator_character[index] = player.character
		global.patreon.player_spectator_force[index] = player.force
		--store character logistics slots due to an apparent bug in the base game that discards them when returning from spectate
		global.patreon.player_spectator_logistics_slots[index] = {}
		for slot=1, player.character.request_slot_count do
			global.patreon.player_spectator_logistics_slots[index][slot] = player.character.get_request_slot(slot)
		end
		player.set_controller { type = defines.controllers.god }
	end
	player.force = game.forces["Patreon"]
	player.print("You are now a spectator")
end

function patreon_reveal(event)
	if (game.tick % 1800 == 0) then
		game.forces.Patreons.chart_all()
	end
end

Event.register(-1, function()
	if not game.forces.Patreons then
		game.create_force("Patreons")
	end
end)

Event.register(defines.events.on_force_created, function(event)
	if(event.force.name ~= "Patreons") then
		if not game.forces.Patreons then
			game.create_force("Patreons")
		end
		event.force.set_cease_fire(game.forces.Patreons, true)
		game.forces.Patreons.set_cease_fire(event.force, true)
	end
end)

Event.register(defines.events.on_player_joined_game, patreon_shoutout)
Event.register(defines.events.on_player_joined_game, patreon_joined)
Event.register(defines.events.on_tick, patreon_reveal)
Event.register(defines.events.on_gui_click, patreon_gui_click)