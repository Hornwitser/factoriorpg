local maze_too_small = "\n\nToo many ore spawns for the given maze size!"
local size_amounts = {0.5, 0.65, 0.7, 0.85, 1.0}
local quantity_amounts = {1, 1.5, 2, 2.5, 3}
local frequency_amounts = {0.3, 0.65, 1, 1.35, 1.7}

--require "heximazing" --A few tweaks.  Disables logistics and radars.

hexi = {}

--Config stuff

local function get_autoplace_amount(amount)
    if amount == "none" then return 0 end
    if amount == "very-low" or amount == "very-small" or amount == "very-poor" then return 1 end
    if amount == "low" or amount == "small" or amount == "regular" then return 2 end
    if amount == "normal" or amount == "medium" or amount == "regular" then return 3 end
    if amount == "high" or amount == "big" or amount == "good" then return 4 end
    if amount == "very-high" or amount == "very-big" or amount == "very-good" then return 5 end
    
    log("Bad autoplace value: " .. amount)
    return 3
end

function hexi.init()

    --local settings = global.maze_settings.global --Not valid for a scenario.
    global.maze_settings = {}
    
    global.maze_settings.maze_width = 32
    global.maze_settings.maze_height = 32
    local maze_total_cells = global.maze_settings.maze_width * global.maze_settings.maze_height
    
    global.maze_settings.maze_tile_size = 512
    global.maze_settings.maze_tile_border = 320
    
    global.maze_settings.maze_width_raw = (global.maze_settings.maze_width+1) * global.maze_settings.maze_tile_size
    global.maze_settings.maze_height_raw = (global.maze_settings.maze_height+1) * global.maze_settings.maze_tile_size
    
    global.maze_settings.ore_multiplier = 1
    global.maze_settings.start_ore_multiplier = 2
    
    global.maze_settings.spawn_cutout = 0
    if global.maze_settings.spawn_cutout >= global.maze_settings.maze_width - 1 then
        global.maze_settings.spawn_cutout = global.maze_settings.maze_width - 1
    end
    if global.maze_settings.spawn_cutout >= global.maze_settings.maze_height - 1 then
        global.maze_settings.spawn_cutout = global.maze_settings.maze_height - 1
    end
    
    global.maze_settings.ore_spawn_grass = false
    global.maze_settings.ore_spawn_grass_start = true
    global.maze_settings.block_crossroad = true
    global.maze_settings.disable_water = false
    global.maze_settings.correct_size = true
    if global.maze_settings.disable_water then
        --No point having these run too
        global.maze_settings.ore_spawn_grass = false
        global.maze_settings.ore_spawn_grass_start = false
    end
    
    local surf_settings = game.surfaces[1].map_gen_settings.autoplace_controls
    
    global.maze_settings.ore_options = {}
    local ores = global.maze_settings.ore_options
    for k,v in pairs(game.entity_prototypes) do
        if v.type == "resource" and v.autoplace_specification then
            local collide = v.collision_box
            if math.abs(collide.left_top.x - collide.right_bottom.x) < 1 and math.abs(collide.left_top.y - collide.right_bottom.y) < 1 then
                local autoplace = v.autoplace_specification
                local autoplace_controls = surf_settings[autoplace.control]
                local count, mult, size = get_autoplace_amount(autoplace_controls.frequency), get_autoplace_amount(autoplace_controls.richness), get_autoplace_amount(autoplace_controls.size)
                if size > 0 then
                    local ore_count = frequency_amounts[count] * maze_total_cells * math.sqrt(autoplace.coverage * autoplace.coverage * autoplace.coverage) * 7
                    local ore_size = size_amounts[size]
                    if global.maze_settings.correct_size then
                        local ore_size_area = ore_size * ore_size
                        
                        local count_low, count_high = math.floor(ore_count), math.ceil(ore_count)
                        local size_low_area, size_high_area = ore_size_area * ore_count / count_low, ore_size_area * ore_count / count_high
                        local size_low, size_high = math.sqrt(size_low_area), math.sqrt(size_high_area)
                        
                        if count_low > 0 and math.abs(size_low - ore_size) < math.abs(size_high - ore_size) then
                            ore_count = count_low
                            ore_size = size_low
                        else
                            ore_count = count_high
                            ore_size = size_high
                        end
                    else
                        if ore_count < 1 then ore_count = 1
                        else ore_count = math.floor(ore_count + 0.5) end
                    end
                    
                    ores[autoplace.control] = {
                        name = autoplace.control,
                        count = ore_count,
                        size = ore_size,
                        ore_scale = {
                            start = autoplace.richness_base * quantity_amounts[mult] * 50,
                            mult = autoplace.richness_multiplier / autoplace.richness_multiplier_distance_bonus * quantity_amounts[mult]
                        }
                    }
                    log("Ore data for "..autoplace.control..": "..ores[autoplace.control].count..", "..ores[autoplace.control].size..", "..ores[autoplace.control].ore_scale.start..", "..ores[autoplace.control].ore_scale.mult)
                end
            end
        end
    end
    
    -- global.maze_settings.spawn_ore_names = {}
    -- local start_ores = global.maze_settings.spawn_ore_names
    -- for i in global.maze_settings.spawn_ore_names:gmatch("[^,]+") do
    --     if ores[i] then start_ores[#start_ores+1] = i
    --     else start_ores[#start_ores+1] = "" end
    -- end
    global.maze_settings.spawn_ore_names = {"iron-ore", "copper-ore", "stone", "coal"}

    game.forces.player.set_spawn_position({global.maze_settings.maze_width_raw/2 - 2, global.maze_settings.maze_height_raw/2 - 2}, 1)
    
end

--End of config stuff

local function get_random_maze_val(cur_seed)
    local new_seed =   bit32.bor(cur_seed   + 0x9E3779B9, 0)
    local return_val = bit32.bor(new_seed   * 0xBF58476D, 0)
    return_val =       bit32.bor(return_val * 0x94D049BB, 0)
    return new_seed,   bit32.bor(return_val             , 0)
end

local last_maze_x, last_maze_y, last_maze = nil, nil, nil
local function get_maze(x, y, seed, width, height, settings)
    if last_maze and last_maze_x == x and last_maze_y == y then return last_maze end
    
    if not global.maze_data then global.maze_data = {} end
    if not global.maze_data[x] then global.maze_data[x] = {} end
    if global.maze_data[x][y] then
        last_maze = global.maze_data[x][y]
        last_maze_x = x
        last_maze_y = y
        return last_maze
    end
    
    local maze_data = {}
    local grid = {}
    for tx = 1,width do
        maze_data[tx] = {}
        grid[tx] = {}
        for ty = 1,height do
            maze_data[tx][ty] = 3
            grid[tx][ty] = true
        end
    end
    
    local maze_seed = bit32.bxor(bit32.lshift(x,16) + bit32.band(y,65535), seed)
    local value = 0
    
    local queue = {}
    maze_seed, value = get_random_maze_val(maze_seed)
    local pos = {0, 0}
    pos[1] = value % width  + 1
    value = bit32.rshift(value,16)
    pos[2] = value % height + 1
    
    if global.maze_settings.spawn_cutout > 0 then
        if x == 0 then
            if y == 0 then
                if pos[1] <= global.maze_settings.spawn_cutout and pos[2] <= global.maze_settings.spawn_cutout then pos[1] = global.maze_settings.spawn_cutout+1 end
                for mx=1,settings.spawn_cutout do
                    for my=1,settings.spawn_cutout do
                        grid[mx][my] = false
                        maze_data[mx][my] = 0
                    end
                end
            elseif y == -1 then
                if pos[1] <= global.maze_settings.spawn_cutout and pos[2] > height-settings.spawn_cutout then pos[1] = global.maze_settings.spawn_cutout+1 end
                for mx=1,settings.spawn_cutout do
                    for my=height,height-settings.spawn_cutout+1,-1 do
                        grid[mx][my] = false
                        maze_data[mx][my] = 0
                        if my == height-settings.spawn_cutout+1 then maze_data[mx][my] = 2 end
                    end
                end
            end
        elseif x == -1 then
            if y == 0 then
                if pos[1] > width-settings.spawn_cutout and pos[2] <= global.maze_settings.spawn_cutout then pos[1] = width-settings.spawn_cutout end
                for mx=width,width-settings.spawn_cutout+1,-1 do
                    for my=1,settings.spawn_cutout do
                        grid[mx][my] = false
                        maze_data[mx][my] = 0
                        if mx == width-settings.spawn_cutout+1 then maze_data[mx][my] = 1 end
                    end
                end
            elseif y == -1 then
                if pos[1] > width-settings.spawn_cutout and pos[2] > height-settings.spawn_cutout then pos[1] = width-settings.spawn_cutout end
                for mx=width,width-settings.spawn_cutout+1,-1 do
                    for my=height,height-settings.spawn_cutout+1,-1 do
                        grid[mx][my] = false
                        maze_data[mx][my] = 0
                        if mx == width-settings.spawn_cutout+1 then maze_data[mx][my] = 1 end
                        if my == height-settings.spawn_cutout+1 then maze_data[mx][my] = maze_data[mx][my] + 2 end
                    end
                end
            end
        end
    end
    
    queue[#queue+1] = {pos[1], pos[2], pos[1]-1, pos[2]  }
    queue[#queue+1] = {pos[1], pos[2], pos[1]+1, pos[2]  }
    queue[#queue+1] = {pos[1], pos[2], pos[1]  , pos[2]-1}
    queue[#queue+1] = {pos[1], pos[2], pos[1]  , pos[2]+1}
    
    while #queue > 0 do
        maze_seed, value = get_random_maze_val(maze_seed)
        local connection = table.remove(queue, value % #queue + 1)
        local sx, sy = connection[1], connection[2]
        local tx, ty = connection[3], connection[4]
        if tx > 0 and ty > 0 and tx <= width and ty <= height and grid[tx][ty] then
            local dx, dy = sx - tx, sy - ty
            local mod_s, mod_t = 3, 3
            if dy == 1 then
                mod_s = 1
            elseif dy == -1 then
                mod_t = 1
            elseif dx == 1 then
                mod_s = 2
            else
                mod_t = 2
            end
            maze_data[sx][sy] = bit32.band(maze_data[sx][sy], mod_s)
            maze_data[tx][ty] = bit32.band(maze_data[tx][ty], mod_t)
            
            grid[sx][sy] = false
            grid[tx][ty] = false
    
            queue[#queue+1] = {tx, ty, tx-1, ty  }
            queue[#queue+1] = {tx, ty, tx+1, ty  }
            queue[#queue+1] = {tx, ty, tx  , ty-1}
            queue[#queue+1] = {tx, ty, tx  , ty+1}
        end
    end
    
    local min_x, min_y, max_x, max_y = 1, 1, width, height
    if x == 0 then
        if y == 0 then
            min_x = 1 + global.maze_settings.spawn_cutout
            min_y = 1 + global.maze_settings.spawn_cutout
        elseif y == -1 then
            max_y = height - global.maze_settings.spawn_cutout
        end
    elseif x == -1 then
        if y == 0 then
            max_x = width - global.maze_settings.spawn_cutout
        end
    end
    
    maze_seed, value = get_random_maze_val(maze_seed)
    maze_data[min_x + bit32.band(value, 0xFFFF) % (max_x-min_x+1)][1] = bit32.band(maze_data[min_x + bit32.band(value, 0xFFFF) % (max_x-min_x+1)][1], 1)
    value = bit32.rshift(value, 16)
    maze_data[1][min_y + bit32.band(value, 0xFFFF) % (max_y-min_y+1)] = bit32.band(maze_data[1][min_y + bit32.band(value, 0xFFFF) % (max_y-min_y+1)], 2)
    
    min_x, min_y, max_x, max_y = 1, 1, width, height
    if x == 0 then
        if y == 0 then
            min_x = 1 + global.maze_settings.spawn_cutout
            min_y = 1 + global.maze_settings.spawn_cutout
        elseif y == -1 then
            max_y = height - global.maze_settings.spawn_cutout
        end
    elseif x == -1 then
        if y == 0 then
            max_x = width - global.maze_settings.spawn_cutout
        end
    end
    
    maze_seed, value = get_random_maze_val(maze_seed)
    maze_data[width+1] = {0, 0}
    maze_data[width+1][1] = min_x + bit32.band(value, 0xFFFF) % (max_x-min_x+1)
    value = bit32.rshift(value, 16)
    maze_data[width+1][2] = min_y + bit32.band(value, 0xFFFF) % (max_y-min_y+1)
    
    global.maze_data[x][y] = maze_data
    last_maze = maze_data
    last_maze_x = x
    last_maze_y = y
    return maze_data
end

local last_maze_ore_x, last_maze_ore_y, last_maze_ore = nil, nil, nil
local function get_maze_ore(x, y, seed, width, height, settings)
    if last_maze_ore and last_maze_ore_x == x and last_maze_ore_y == y then return last_maze_ore end
    
    if not global.maze_data_ore then global.maze_data_ore = {} end
    if not global.maze_data_ore[x] then global.maze_data_ore[x] = {} end
    if global.maze_data_ore[x][y] then
        last_maze_ore = global.maze_data_ore[x][y]
        last_maze_ore_x = x
        last_maze_ore_y = y
        return last_maze_ore
    end
    
    local min_x, min_y, max_x, max_y = -1, -1, -1, -1
    if global.maze_settings.spawn_cutout > 0 then
        if x == 0 then
            if y == 0 then
                min_x, min_y, max_x, max_y = 1, 1, global.maze_settings.spawn_cutout, global.maze_settings.spawn_cutout
            elseif y == -1 then
                min_x, min_y, max_x, max_y = 1, height-settings.spawn_cutout+1, global.maze_settings.spawn_cutout, height
            end
        elseif x == -1 then
            if y == 0 then
                min_x, min_y, max_x, max_y = width-settings.spawn_cutout+1, 1, width, global.maze_settings.spawn_cutout
            elseif y == -1 then
                min_x, min_y, max_x, max_y = width-settings.spawn_cutout+1, height-settings.spawn_cutout+1, width, height
            end
        end
    end
    
    local coord_list = {}
    local maze_data = {}
    for tx=1,width do
        maze_data[tx] = {}
        for ty=1,height do
            if tx < min_x or tx > max_x or ty < min_y or ty > max_y then
                coord_list[#coord_list+1] = {tx,ty}
            end
        end
    end
    
    local maze_seed = bit32.bxor(bit32.lshift(x,16) + bit32.band(y,65535), seed)
    local value = 0
    
    for k,v in pairs(global.maze_settings.ore_options) do
        for a=1,v.count do
            maze_seed, value = get_random_maze_val(maze_seed)
            local pos = table.remove(coord_list, value % #coord_list + 1)
            if not pos then error(maze_too_small) end
            maze_data[pos[1]][pos[2]] = v.name
        end
    end
    
    global.maze_data_ore[x][y] = maze_data
    last_maze_ore = maze_data
    last_maze_ore_x = x
    last_maze_ore_y = y
    return maze_data
end

local function global_to_maze_pos(x, y, settings)
    --Ensures we start in the middle of a tile.
    x = x + global.maze_settings.maze_tile_size/2
    y = y + global.maze_settings.maze_tile_size/2
    
    local maze_width_raw  = (global.maze_settings.maze_width +1) * global.maze_settings.maze_tile_size
    local maze_height_raw = (global.maze_settings.maze_height+1) * global.maze_settings.maze_tile_size
    
    local global_maze_x = math.floor(x / global.maze_settings.maze_width_raw)
    local global_maze_y = math.floor(y / global.maze_settings.maze_height_raw)
    x = x - global_maze_x * global.maze_settings.maze_width_raw
    y = y - global_maze_y * global.maze_settings.maze_height_raw
    
    local inner_x, inner_y = x, y
    
    local local_maze_x = math.floor(x / global.maze_settings.maze_tile_size)
    local local_maze_y = math.floor(y / global.maze_settings.maze_tile_size)
    x = x - local_maze_x * global.maze_settings.maze_tile_size
    y = y - local_maze_y * global.maze_settings.maze_tile_size
    
    return global_maze_x, global_maze_y, local_maze_x, local_maze_y, x, y
end

local function handle_maze_tile(x, y, surf, seed, settings)
    local orig_x, orig_y = x, y
    local global_maze_x, global_maze_y, local_maze_x, local_maze_y = 0, 0, 0, 0
    global_maze_x, global_maze_y, local_maze_x, local_maze_y, x, y = global_to_maze_pos(x, y, settings)
    
    local almost_cutout = false
    if settings.spawn_cutout > 0 and (global_maze_x == 0 or global_maze_x == -1) and (global_maze_y == 0 or global_maze_y == -1) then
        local local_global_x = global_maze_x * (global.maze_settings.maze_width+2) + local_maze_x
        local local_global_y = global_maze_y * (global.maze_settings.maze_height+2) + local_maze_y
        if math.abs(local_global_x) < global.maze_settings.spawn_cutout+1 and math.abs(local_global_y) < global.maze_settings.spawn_cutout+1 then return nil end
        
        if (global_maze_x == -1 and global_maze_y == 0 and local_global_x == -settings.spawn_cutout - 1 and local_global_y == 0) or (global_maze_x == 0 and global_maze_y == -1 and local_global_x == 0 and local_global_y == -settings.spawn_cutout - 1) then almost_cutout = true end
    end
    
    local maze_data = get_maze(global_maze_x, global_maze_y, seed, global.maze_settings.maze_width, global.maze_settings.maze_height, settings)
    local maze_value = 0
    if local_maze_x == 0 or local_maze_y == 0 then
        if local_maze_x == 0 then
            if local_maze_y ~= 0 then
                if maze_data[settings.maze_width+1][2] ~= local_maze_y then maze_value = 1 end
                if global.maze_settings.block_crossroad and (global_maze_x ~= 0 or global_maze_y ~= 0) and local_maze_y == 1 then maze_value = maze_value + 2 end
            end
        else 
            if maze_data[settings.maze_width+1][1] ~= local_maze_x then maze_value = 2 end
            if global.maze_settings.block_crossroad and (global_maze_x ~= 0 or global_maze_y ~= 0) and local_maze_x == 1 then maze_value = maze_value + 1 end
        end
    else
        maze_value = maze_data[local_maze_x][local_maze_y]
    end
    
    if x < global.maze_settings.maze_tile_border and y < global.maze_settings.maze_tile_border then return {name = "out-of-map", position = {orig_x, orig_y}} end
    if almost_cutout then return nil end
    if x < global.maze_settings.maze_tile_border and bit32.btest(maze_value,1) then return {name = "out-of-map", position = {orig_x, orig_y}} end
    if y < global.maze_settings.maze_tile_border and bit32.btest(maze_value,2) then return {name = "out-of-map", position = {orig_x, orig_y}} end
    if global.maze_settings.block_crossroad and (global_maze_x ~= 0 or global_maze_y ~= 0) and local_maze_x == 0 and local_maze_y == 0 then return {name = "out-of-map", position = {orig_x, orig_y}} end
    if global.maze_settings.disable_water then
        local name = surf.get_tile(orig_x, orig_y).name
        if name == "water" or name == "deepwater" then return {name = "grass-1", position = {orig_x, orig_y}} end
    end
    return nil
end

local function handle_maze_tile_ore(x, y, surf, seed, settings)
    local orig_x, orig_y = x, y
    local global_maze_x, global_maze_y, local_maze_x, local_maze_y = 0, 0, 0, 0
    global_maze_x, global_maze_y, local_maze_x, local_maze_y, x, y = global_to_maze_pos(x, y, settings)
    
    if x < global.maze_settings.maze_tile_border or y < global.maze_settings.maze_tile_border then return end
    
    local seed_x = global_maze_x * global.maze_settings.maze_width + local_maze_x
    local seed_y = global_maze_x * global.maze_settings.maze_height + local_maze_y
    
    local ore_name = nil
    local start_zone = false
    if local_maze_x == 0 or local_maze_y == 0 then
        start_zone = true
        if global.maze_settings.start_ore_multiplier > 0 then
            if global_maze_x == 0 and global_maze_y == 0 then
                if local_maze_x == 1 and local_maze_y == 0 then ore_name = global.maze_settings.spawn_ore_names[2] end
                if local_maze_x == 0 and local_maze_y == 1 then ore_name = global.maze_settings.spawn_ore_names[3] end
            elseif global_maze_x == -1 and global_maze_y == 0 and local_maze_x == global.maze_settings.maze_width and local_maze_y == 0 then ore_name = global.maze_settings.spawn_ore_names[4]
            elseif global_maze_x == 0 and global_maze_y == -1 and local_maze_x == 0 and local_maze_y == global.maze_settings.maze_height then ore_name = global.maze_settings.spawn_ore_names[1]
            end
        end
    elseif global.maze_settings.ore_multiplier > 0 then
        local maze_data = get_maze_ore(global_maze_x, global_maze_y, seed, global.maze_settings.maze_width, global.maze_settings.maze_height, settings)
        ore_name = maze_data[local_maze_x][local_maze_y]
    end
    
    if ore_name then
        local dist_x = orig_x
        local dist_y = orig_y
        --if dist_x < 0 then dist_x = dist_x * -1 end
        --if dist_y < 0 then dist_y = dist_y * -1 end
        
        local dist = math.abs(dist_x * dist_y)^0.6
        --if dist_y > dist then dist = dist_y end
        
        local resource_amount_max =global.maze_settings.ore_options[ore_name].ore_scale.start +global.maze_settings.ore_options[ore_name].ore_scale.mult * dist
        
        local dist_x = global.maze_settings.maze_tile_size - x - 1
        if (x - global.maze_settings.maze_tile_border) < dist_x then dist_x = (x - global.maze_settings.maze_tile_border) end
        local dist_y = global.maze_settings.maze_tile_size - y - 1
        if (y - global.maze_settings.maze_tile_border) < dist_y then dist_y = (y - global.maze_settings.maze_tile_border) end
        
        dist = dist_x
        if dist_y < dist then dist = dist_y end
        dist = dist + 1
        
        local cell_dist = dist / (settings.maze_tile_size - settings.maze_tile_border) * 2
        local ore_size =global.maze_settings.ore_options[ore_name].size
        
        if cell_dist > 1-ore_size then
            if (global.maze_settings.ore_spawn_grass or (start_zone and global.maze_settings.ore_spawn_grass_start)) and not surf.can_place_entity{name=ore_name, position={orig_x, orig_y}} then
                game.surfaces[1].set_tiles({{name = "grass-1", position = {orig_x, orig_y}}}, true)
            end
            if surf.can_place_entity{name=ore_name, position={orig_x, orig_y}} then
                cell_dist = 1-(1-cell_dist)/ore_size

                local resource_amount = resource_amount_max * cell_dist
                if start_zone then resource_amount = resource_amount * global.maze_settings.start_ore_multiplier
                else resource_amount = resource_amount * global.maze_settings.ore_multiplier end
                resource_amount = resource_amount / (global.maze_settings.maze_tile_size * global.maze_settings.maze_tile_size) * 20
                if resource_amount < 1 then resource_amount = 1 end
                
                surf.create_entity{name=ore_name, position={orig_x, orig_y}, amount=resource_amount}
            end
        end
    end
end

local function on_chunk_generated_ore(event, settings)
    local entities = event.surface.find_entities(event.area)
    for _, entity in pairs(entities) do
        if entity.type == "resource" then
            if global.maze_settings.ore_options[entity.name] then entity.destroy() end
        end
    end
    
    local tx, ty = event.area.left_top.x, event.area.left_top.y
    local ex, ey = event.area.right_bottom.x, event.area.right_bottom.y
    
    for x=tx,ex do
        for y=ty,ey do
            handle_maze_tile_ore(x, y, game.surfaces[1], global.maze_seed, settings)
        end
    end
end

function hexi.on_chunk_generated(event)
    local settings = global.maze_settings
    
    if not global.maze_seed then global.maze_seed = math.random(0, 65536 * 65536 - 1) end
    
    local tiles = {}
    local tx, ty = event.area.left_top.x, event.area.left_top.y
    local ex, ey = event.area.right_bottom.x, event.area.right_bottom.y
    
    for x=tx,ex do
        for y=ty,ey do
            local new_tile = handle_maze_tile(x, y, game.surfaces[1], global.maze_seed, settings)
            if new_tile then table.insert(tiles, new_tile) end
        end
    end
    game.surfaces[1].set_tiles(tiles, true)
    
    --on_chunk_generated_ore(event, settings) --Don't generate ore according to Hexicube logic.
    --Clear out near the spawn position
    if math.abs(event.area.left_top.x - game.forces.player.get_spawn_position(event.surface).x) < 400 then
        for k, v in pairs(event.surface.find_entities_filtered{force="enemy", area=event.area}) do
            v.destroy()
        end
    end
    --Correct ores to reduce the natural distance gain.
    for k,v in pairs(event.surface.find_entities_filtered{type="resource", area=event.area}) do
        v.amount = v.amount ^ 0.8
    end

end

Event.register(defines.events.on_chunk_generated, hexi.on_chunk_generated)
Event.register(-1, hexi.init)