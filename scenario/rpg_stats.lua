-- Track silly useless statistics across sessions.
-- Written by Mylon, Sept 2018

rpg_stats = {}

--Build the table for our player.  Called just before we load data
function rpg_stats.init_player(event)
    local player = game.players[event.player_index]
    local name = player.name
    global.rpg_data[name].stats = 
    {
        ["travelled"] = {
            ["walking"] = 0,
            ["driving"] = 0,
            ["trained"] = 0
        },
        ["kills"] = {
            ["biters"] = {
                ["turret"] = 0,
                ["robot"] = 0,
                ["roadkill"] = 0,
                ["direct"] = 0
            },
            ["bases"] = {
                ["turret"] = 0,
                ["robot"] = 0,
                ["roadkill"] = 0,
                ["direct"] = 0,
            }
        },
        ["built"] = {
            ["belts"] = 0,
            ["inserters"] = 0,
            ["crafting machines"] = 0,
            ["via bots"] = 0
        },
        ["tiles laid"] = 0,
        ["land filled"] = 0,
        ["built by robot"] = 0,
        ["mined ore"] = 0,
        ["trees cut"] = 0,
        ["rocks broken"] = 0,
        ["playtime"] = 0
    }
end

--Build the window
function rpg_stats.display(player)
    local gui = player.gui.center.add("window")
    player.opened = gui
end

function rpg_stats.walked(event)
    local player = game.players[event.player_index]
    if player.walking_state.walking then
        global.rpg_data[player.name].stats.travelled.walking = global.rpg_data[player.name].stats.travelled.walking + 1
        return
    end
    if (player.vehicle and player.vehicle.type == "car" and player.vehicle.speed ~= 0) then
        global.rpg_data[player.name].stats.travelled.driving = global.rpg_data[player.name].stats.travelled.driving + 1
        return
    end
    --Train!
    if (player.vehicle and player.vehicle.train) then
        global.rpg_data[player.name].stats.travelled.trained = global.rpg_data[player.name].stats.travelled.trained + 1
        return
    end
end

function rpg_stats.slaughter(event)
    if not (event.entity and event.entity.force.name == "enemy" and event.cause and (event.cause.type == "player" or event.cause.last_user)) then
        return
    end
    local name = event.cause.name or event.cause.last_user
    local type
    if event.entity.type == "unit" then
        type = "biters"
    end
    if event.entity.type == "spawner" then
        type = "bases"
    end
    --Maybe if we're doing PvP or weird scenarios.
    if not type then return end

    if (event.cause.type == "ammo-turret" or event.cause.type == "laser-turret" or event.cause.type == "flame-turret") then
        global.rpg_data[name].stats.kills[type].turret = global.rpg_data[name].stats.kills[type].turret + 1
        return
    end
    if event.cause.type == "combat-robot" then
        global.rpg_data[name].stats.kills[type].robot = global.rpg_data[name].stats.kills[type].robot + 1
        return
    end
    if event.cause.type == "car" or event.cause.type == "train" then
        global.rpg_data[name].stats.kills[type].roadkill = global.rpg_data[name].stats.kills[type].roadkill + 1
        return
    end
    if event.cause.type == "player" then
        global.rpg_data[name].stats.kills[type].direct = global.rpg_data[name].stats.kills[type].direct + 1
        return
    end
    --Still here?  Some other method was used. (flame?  Poison?)
end

function rpg_stats.building(event)
    if not event.built_entity.last_user then return end
    local name = event.built_entity.last_user.name
    if not name then return end
    if event.built_entity.type == "transport-belt" or event.built_entity.type == "splitter" or event.built_entity.type == "underground-belt" then
        key = "belts"
    end
    if event.built_entity.type == "inserter" then
        key = "inserter"
    end
    if event.built_entity.type == "assembling-machine" or event.built_entity.type == "chemical-plant" or event.built_entity.type == "oil-refinery" or event.built_entity.type == "centrifuge" then
        key = "crafting machine"
    end

    global.rpg_data[name].stats.built[key] = global.rpg_data[name].stats.built[key] + 1

end

function rpg_stats.robot_building(event)
    local name = event.built_entity.last_user.name

    global.rpg_data[name].stats.built["by robot"] = global.rpg_data[name].stats.built["by robot"] + 1
end

function rpg_stats.brick_layer(event)
    local name = game.players[event.player_index].name
    local key = "tiles laid"
    if event.item.name == "landfill" then
        key = "land filled"
    end
    global.rpg_data[name].stats[key] = global.rpg_data[name].stats[key] + #event.tiles
end

function rpg_stats.hand_mine(event)
    local name = game.players[event.player_index].name
    local type = event.entity.type
    if not (type == "tree" or type == "simple-entity" or type == "ore") then return end
    local key
    if type == "simple-entity" then
        key = "rocks broken"
    end
    if type == "tree" then
        key = "trees cut"
    end
    if type == "resource" then
        key = "mined ore"
    end
    global.rpg_data[name].stats[key] = global.rpg_data[name].stats[key] + 1
end

Event.register(defines.events.on_player_created, rpg_stats.init_player)
Event.register(defines.events.on_player_changed_position, rpg_stats.walked)
Event.register(defines.events.on_entity_died, rpg_stats.slaughter)
Event.register(defines.events.on_built_entity, rpg_stats.building)
Event.register(defines.events.on_robot_built_entity, rpg_stats.robot_building)
Event.register(defines.events.on_player_built_tile, rpg_stats.brick_layer)
Event.register(defines.events.on_player_mined_entity, rpg_stats.hand_mine)