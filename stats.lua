-- Stats Module
-- Made by: Viceroypenguin (@viceroypenguin#8303 on discord) for FactorioMMO
-- This module generates stats and writes them to file in JSON format

global.stats_save_to_file = true
global.stats_save_to_log = false

global.stats_save_every_x_seconds = 10

local function stats_build_stats_json(stats)
    local str = ""
    for k, v in pairs(stats.input_counts) do
      str = str .. "{ \"entity_name\": \"" .. k .. "\", \"amount\": " .. v .. " }, "
    end

    str = string.sub(str, 1, -3)
    return str
end

local function get_player_count()
    local tplayers = 0
    local cplayers = 0
    for i, x in pairs(game.players) do
        tplayers = tplayers + 1
        if x.connected then
            cplayers = cplayers + 1
        end
    end
    return "\"players\":" .. tplayers .. ", \"players_online\":" .. cplayers .. ", "
end

local function stats_generate_stats()
    local str = "{ \"tick\": " .. game.tick .. ", \"speed\": " .. game.speed .. ", " .. get_player_count()
    local force = game.forces["player"]
    
    local prod_str = stats_build_stats_json(force.item_production_statistics) .. ", " .. stats_build_stats_json(force.fluid_production_statistics)
    str = str .. "\"entities_produced\": [" .. prod_str .. "], "
    
    str = str .. "\"entities_killed\": [" .. stats_build_stats_json(force.kill_count_statistics) .. "], "
    str = str .. "\"entities_placed\": [" .. stats_build_stats_json(force.entity_build_count_statistics) .. "] " .. "}"
 
    if global.stats_save_to_file then
        local file_name = "stats_" .. game.tick .. ".json"
        game.write_file(file_name, str, false)
    end

    if global.stats_save_to_log then
        fmcd_print("STATS", "PROD", str)
    end
end

Event.register(defines.events.on_player_died, function(event)
    local str = "{ \"tick\": " .. game.tick .. ", \"player\": " .. game.players[event.player_index].name .. ", \"cause\": " .. event.cause.name .. " }"

    if global.stats_save_to_file then
        local file_name = "death_" .. event.player_index .. "_" .. game.tick .. ".json"
        game.write_file(file_name, str, false)
    end

    if global.stats_save_to_log then
        fmcd_print("STATS", "DEATH", str)
    end
end)

Event.register(defines.events.on_tick, function(event)
    local tick = game.tick
        
    if tick % 600 == 0 then
        stats_generate_stats()
    end
end)

Event.register('on_init', function(event)
end)

