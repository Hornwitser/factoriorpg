TRUST_COUNT = 3
global.vetting = {}

--Note, this command relies on a hardcoded group named "trusted"
--Name is case insensitive.
commands.add_command("vet", "Vet a player as trusted.", function(params)
	local name = params.parameter
	if not game.player then --Server cannot run this command.
		return
	end
	if name == nil then
		game.player.print("Do /vet <name> to vet that player.")
		return
	end
	name = name:lower()
	if global.vetting[game.player.name] then
		game.player.print("Vetted players cannot vet.")
		return
	end
	if not (game.players[name]) then
		game.player.print("Invalid name.")
		return
	end
	if not (game.player.permission_group == game.permissions.get_group("trusted")) then
		game.player.print("Must be trusted to use this command.")
		return
	end
	if not (game.players[name].permission_group == game.permissions.get_group("trusted")) then
		if not global.vetting[name] then
			global.vetting[name] = {}
		end
		if not global.vetting[name][game.player.name] then
			global.vetting[name][game.player.name] = true
			if #global.vetting[name] >= TRUST_COUNT or #global.vetting[name] == #game.connected_players - 1 then
				game.players[name].permission_group = game.permissions.get_group("trusted")
				game.players[name].print("Players have vetted you and given you permissions.")
			end
		else
			game.player.print("You have already vetted " .. params.parameter .. ".")
		end
		game.player.print("You have vetted " .. params.parameter .. ".")
	else
		game.player.print("Player is already trusted.")
	end

end)

function auto_promote(event)
	local player = game.players[event.player_index]
	if not (player and player.valid) then
		return
	end
	if player.admin then
		player.permission_group = game.permissions.get_group("trusted")
	end
end

function rpg_permissions_init()
	local default = game.permissions.groups[1]
	default.set_allows_action(defines.input_action.deconstruct, false)
	default.set_allows_action(defines.input_action.change_programmable_speaker_parameters, false)
	default.set_allows_action(defines.input_action.edit_custom_tag, false)
	default.set_allows_action(defines.input_action.delete_custom_tag, false)
	--No changing train stations
	--This one ought to cover most of the bases...
	default.set_allows_action(defines.input_action.open_train_gui, false)
	default.set_allows_action(defines.input_action.set_train_stopped, false)
	default.set_allows_action(defines.input_action.change_train_stop_station, false)
	game.permissions.create_group("trusted") --For level 5+ players.
end

Event.register(defines.events.on_player_joined_game, auto_promote)
Event.register(-1, rpg_permissions_init)