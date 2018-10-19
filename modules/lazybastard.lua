--Ultra slow handcrafting
--By Mylon, March 2018
--MIT license

lazy = {}

function lazy.init()
    game.forces.player.manual_crafting_speed_modifier = 1 / 200 - 1
end

function lazy.tool(event)
    local player = game.players[event.player_index]
    if player and player.valid then
        player.insert{name="assembling-machine-1"}
    end
end

function lazy.craft_speed(event)
    event.force.manual_crafting_speed_modifier = 1 / 200 - 1
end

if rpg then
	Event.register(rpg.on_reset_technology_effects, lazy.craft_speed)
end
Event.register(-1, lazy.init)
Event.register(defines.events.on_player_created, lazy.tool)
