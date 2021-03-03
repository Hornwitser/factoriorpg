-- Trusted Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module adds trusted members to the correct permission group and gives a option to check if they are trusted

global.trusted = global.trusted or {}
global.trusted.list = {"Borga", "SockPuppet"}

function trusted_add(command)
	if game.players[command.player_index].admin then
		if command.parameter ~= nil then
			local player = game.players[command.parameter]
			if player ~= nil then
				table.insert(global.trusted.list, player.name)
			end
		else
			game.players[command.player_index].print("Enter a username")
		end
	end
end

function trusted_remove(command)
	if game.players[command.player_index].admin then
		if command.parameter ~= nil then
			local player = game.players[command.parameter]
			if player ~= nil then
				for i, name in pairs(global.trusted.list) do
					if player.name == name then
						global.trusted.list[i] = nil
					end
				end
			end
		else
			game.players[command.player_index].print("Enter a username")
		end
	end
end

function trusted_check(player_name)
	for i, name in pairs (global.trusted.list) do
		if player_name == name then
			return true
		end
	end
	return false
end

function trusted_joined(event)
	local player = game.players[event.player_index]
	if(global.permissions)then
		if(trusted_check(player.name)) then
			permissions_add_player(player, "trusted")
		end
	end
end


return {
	add_commands = function()
		commands.add_command("trust", "Enter the username of the player you want to add to the trusted list.", trusted_add)
		commands.add_command("trust_remove", "Enter the username of the player you want to remove from the trusted list.", trusted_remove)
	end,
	events = {
		[defines.events.on_player_joined_game] = trusted_joined,
	},
}
