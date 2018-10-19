--This Tank Stops for Nobody! - A scenario inspired by Never Stop the Train
--Written by Mylon, 2018
--MIT License, https://opensource.org/licenses/MIT

ttsfn = {}
ttsfn.fuels = {wood = 0.2, ["small-electric-pole"] = 0.2, ["raw-wood"] = 0.2, coal = 0.22, ["solid-fuel"] = 0.25, ["rocket-fuel"] = 0.26, ["nuclear-fuel"] = 0.28 }
ttsfn.surface = {MARGIN = 64, HEIGHT = 128, START_WIDTH = 96, START_HEIGHT = 64}
ttsfn.COAST = 0.2
ttsfn.STARTING_MAX_HP = 100000
ttsfn.RAW_MAX_HP = 2000
ttsfn.MULTITANK_MODE = false
ttsfn.RESOURCES = {"iron-ore", "copper-ore", "coal", "stone", "uranium-ore", "crude-oil"}
ttsfn.MINING_POWER = 6
ttsfn.MINING_ENERGY_CONSUMED = 180000 / 3 * 0.9 --Approximate amount of energy to power a drill to produce 1 ore.
--ttsfn.RAW_MAX_HP = game.entity_prototypes["tank"]. --Tank prototype hp
--global.ttsfn.players[player.name] = {tank=entity, raw_hp_last_tick=float, hp=float, max_hp=float, pos=position, open_spawn=bool, mining_power=int, internal_size=int, auto_turn=float, windbane=bool}
global.ttsfn = {tanks = {}, players = {}, delayed_chart = {}}

function ttsfn.drive(event)
    --Process each tank
    for _, player in pairs(game.players) do
        --Move forward, deduct fuel.
        if not global.ttsfn.players[player.name] then return end

        --This step will skip over crew members.
        local tank = global.ttsfn.players[player.name].tank
        if not (tank and tank.valid) then 
            global.ttsfn.players[player.name].tank = nil
        else
            
            --Tank externals
            --Hit a cliff or water?
            if tank.speed == 0 then
                local orientation = (0.25 - tank.orientation) * 2 * math.pi
                local dx, dy = math.cos( orientation ) * 0.02, -math.sin( orientation ) * 0.02
                tank.teleport({tank.position.x + dx, tank.position.y + dy})
            end

            local speed = global.ttsfn.players[player.name].speed

            --Set speed and deduct fuel
            --local speed = 0
            -- local drivetrain = global.ttsfn.players[player.name].drivetrain
            -- if drivetrain.energy < drivetrain.electric_drain then
            --     if tank.burner.currently_burning then
            --         local burner = tank.burner
            --         speed = ttsfn.fuels[burner.currently_burning.name]
            --         if not speed then
            --             speed = 0
            --             burner.remaining_burning_fuel = 0
            --             log("Unrecognized fuel type.")
            --         end
            --         burner.remaining_burning_fuel = burner.remaining_burning_fuel - 800000 / 60
            --         if burner.remaining_burning_fuel < 0 then
            --             --if burner.inventory[1] and burner.inventory[1].valid and not burner.inventory[1].is_empty() then --May have to check all fuel inventory slots
            --             if burner.inventory[1] and burner.inventory[1].valid_for_read then --May have to check all fuel inventory slots
            --                 burner.currently_burning = burner.inventory[1].prototype
            --                 burner.inventory[1].count = burner.inventory[1].count - 1
            --                 burner.remaining_burning_fuel = burner.inventory[1].prototype.fuel_value
            --             else
            --                 speed = ttsfn.COAST
            --             end
            --         end
            --     end
            -- else
            --     speed = 0.1 * (0.1 + 0.9 * math.max(1, drivetrain.energy / drivetrain.electric_buffer_size))
            -- end

            tank.speed = speed

            if global.ttsfn.players[player.name].windvane then
                tank.orientation = tank.orientation + tank.surface.wind_orientation_change
            else
                tank.orientation = tank.orientation + global.ttsfn.players[player.name].auto_turn
            end
            
            -- Modify the hp
            local dhp = tank.health - global.ttsfn.players[player.name].raw_hp_last_tick
            global.ttsfn.players[player.name].hp = global.ttsfn.players[player.name].hp + dhp
            --We can't intercept the death event, so the tank has to stay above one-shot territory.  Nukes can still probably bypass this, but players shouldn't be able to fire them anyway.
            tank.health = math.max(100, global.ttsfn.players[player.name].hp / global.ttsfn.players[player.name].max_hp * ttsfn.RAW_MAX_HP)
            
            global.ttsfn.players[player.name].raw_hp_last_tick = tank.health

            --Update the gui
            ttsfn.update_hp(player)

            --Game over condition
            if global.ttsfn.players[player.name].hp <= 0 then
                script.set_game_state{game_finished=true}
            end

            
            --Periodic functions.  We don't need to do this every tick.
            if (game.tick + player.index) % 10 == 0 then
                --Detect and deplete nearby ore.
                local mining_power = math.floor(global.ttsfn.players[player.name].mining_power / 6)
                -- local mining_power = global.ttsfn.players[player.name].mining_power
                if math.random() < (global.ttsfn.players[player.name].mining_power % 6 / 6) then
                    mining_power = mining_power + 1
                end
                --for k,v in pairs(ttsfn.RESOURCES) do
                if mining_power > 0 then
                    local area = {{tank.position.x-10, tank.position.y-10}, {tank.position.x+10, tank.position.y+10}}

                    --Randomize what corner we start at.
                    --DOES NOT WORK
                    -- if math.random() < 0.5 then
                    --     area[1][1], area[2][1] = area[2][1], area[1][1]
                    -- end
                    -- if math.random() < 0.5 then
                    --     area[1][2], area[2][2] = area[2][2], area[1][2]
                    -- end

                    local ore = tank.surface.find_entities_filtered{type="resource", area=area, limit=1}[1]
                    if ore and ore.valid then
                        --Spawn particles.
                        tank.surface.create_entity{name="electric-beam", duration=30, position=tank.position, target=ore.position, source=tank}
                        
                        
                        --Test energy availability.
                        if global.ttsfn.players[player.name].mining_drill.energy < global.ttsfn.players[player.name].mining_drill.electric_buffer_size then
                            local ratio = global.ttsfn.players[player.name].mining_drill.energy / global.ttsfn.players[player.name].mining_drill.electric_buffer_size
                            if mining_power > 0 then
                                mining_power = math.max(1, math.floor(mining_power * ratio))
                            end
                        end
                        
                        local power_draw = mining_power * 90000

                        --Add ore, deduct mining power from drill EEI
                        --ore to add = mining power * force.mining_drill_productivity_bonus
                        local chest = global.ttsfn.players[player.name].chests[ore.name]
                        if chest then
                            chest.insert{name=ore.name, count=math.floor(mining_power * (1+tank.force.mining_drill_productivity_bonus)) }
                            --game.print("Adding ore ".. ore.name)
                            --global.ttsfn.players[player.name].mining_drill.energy = global.ttsfn.players[player.name].mining_drill.energy - power_draw
                        else
                            --game.print("Invalid chest to catch " .. ore.name)
                        end

                        --Deplete ore.
                        if not ore.prototype.infinite_resource and ore.amount <= mining_power then
                            script.raise_event(defines.events.on_resource_depleted, {entity=ore, name=defines.events.on_resource_depleted})
                            if ore and ore.valid then
                                ore.destroy()
                            end
                        else
                            ore.amount = ore.amount - mining_power
                        end
                    end
                end
            
                --In case no one is driving, request to generate chunks so the biters can get their noms on.
                local chunkx, chunky = math.floor(tank.position.x / 32), math.floor(tank.position.y / 32)
                -- for x = -10, 10 do
                --     for y = -10, 10 do
                --         if not tank.surface.is_chunk_generated({chunkx + x, chunky + y}) then
                --             if x > -2 and x < 2 and y > -2 and y < 2 then
                --                 tank.surface.set_chunk_generated_status({chunkx + x, chunky + y}, defines.chunk_generated_status.custom_tiles)
                --             else
                --                 tank.surface.set_chunk_generated_status({chunkx + x, chunky + y}, defines.chunk_generated_status.entities)
                --             end
                --         end
                --     end
                -- end
                --tank.surface.request_to_generate_chunks({chunkx, chunky}, 2)
                tank.surface.request_to_generate_chunks({tank.position.x, tank.position.y}, 2)

                --Do upgrades.
                ttsfn.upgrade(player)
                
                --End periodic functions.
            end


            --Tank internals
            global.ttsfn.players[player.name].water_tank.fluidbox[1] = {name="water", amount=25000}
            global.ttsfn.players[player.name].oil_tank.fluidbox[1] = {name="crude-oil", amount=25000}

            --Every second, collect pollution inside the tank and create it outside.

        end

    end
end

--Each player spawns as a tank.
function ttsfn.create_player(event)
    local player = game.players[event.player_index]
    
    --For single-tank mode, second player and up, skip this and move them inside of the tank.
    if not ttsfn.MULTIPLAYER_MODE and event.player_index > 1 then
        player.teleport({-2, ttsfn.surface.START_HEIGHT / 2 + 6}, "ttsfn")
        return
    end

    --Tank
    local tank = game.surfaces[1].create_entity{name="tank", position = {0,0}, force=game.forces.player}
    local direction = math.random()
    local force = game.forces.player
    tank.insert{name="raw-wood", count=100}
    tank.orientation = direction
    tank.set_driver(player)
    table.insert(global.ttsfn.tanks, tank)
    global.ttsfn.players[player.name] = {tank=tank, max_hp=ttsfn.STARTING_MAX_HP, hp=ttsfn.STARTING_MAX_HP, raw_hp_last_tick=2000}

    --Inner Surface
    local surface = game.surfaces.ttsfn
    local start_x = -1
    local start_y = (event.player_index) * (ttsfn.surface.MARGIN + ttsfn.surface.HEIGHT)
    local tiles = {}
    for x = start_x, -ttsfn.surface.START_WIDTH, -1 do
        for y = start_y, start_y + ttsfn.surface.START_HEIGHT - 1 do
            --Exception: top right triangle remains void.
            if y > start_y + ttsfn.surface.START_HEIGHT / 2 + x then
                table.insert(tiles, {name="concrete", position={x, y}, hidden_tile="brick"})
            end
            global.ttsfn.players[player.name].end_y = y
        end
        global.ttsfn.players[player.name].end_x = x
    end
    surface.set_tiles(tiles)
    force.chart_all(surface)

    --Create a dummy-character in the passenger seat to keep aggro.
    --Passenger controls the gun and picks up loot (stone from rocks), not desirable.
    -- local aggro_magnet = game.surfaces[1].create_entity{name="player", force=force, position={0, 0}}
    -- tank.set_passenger(aggro_magnet)
        
    --Create Gui
    ttsfn.driving_gui(player)

    --Water and oil tanks
    local function protected(entity)
        entity.minable = false
        entity.destructible = false
    end

    global.ttsfn.players[player.name].water_tank = surface.create_entity{name="storage-tank", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + 2}}
    protected(global.ttsfn.players[player.name].water_tank)
    
    global.ttsfn.players[player.name].oil_tank = surface.create_entity{name="storage-tank", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT - 3}}
    protected(global.ttsfn.players[player.name].oil_tank)

    local chest, loader, offset
    --Ore chests
    global.ttsfn.players[player.name].chests = {}
    

    local function make_chest(offset, type)
        chest = surface.create_entity{name="logistic-chest-passive-provider", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}    
        loader = surface.create_entity{name="express-loader", type="output", force=game.forces.player, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}, direction=defines.direction.west}
        loader.rotatable = false
        protected(chest)
        protected(loader)
        global.ttsfn.players[player.name].chests[type] = chest
        local chunkx, chunky = math.floor(chest.position.x/32), math.floor(chest.position.y/32)
        if not global.ttsfn.delayed_chart[surface.index][chunkx] then
            global.ttsfn.delayed_chart[surface.index][chunkx] = {}
        end
        if not global.ttsfn.delayed_chart[surface.index][chunkx][chunky] then
            global.ttsfn.delayed_chart[surface.index][chunkx][chunky] = {}
        end
        table.insert(global.ttsfn.delayed_chart[surface.index][chunkx][chunky], {icon={type="item", name=type}, text=type .. " output chest", target=chest, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + 4 *offset - 50}})
        --force.add_chart_tag(surface, {icon={type="item", name=type}, text=type .. " output chest", target=chest, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}})
    end

    make_chest(5, "raw-wood")
    make_chest(7, "coal")
    make_chest(9, "iron-ore")
    make_chest(11, "copper-ore")
    make_chest(13, "stone")
    make_chest(15, "uranium-ore")

    --Stone
    -- offset = 13
    -- chest = surface.create_entity{name="logistic-chest-passive-provider", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}    
    -- loader = surface.create_entity{name="express-loader", type="output", force=game.forces.player, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}, direction=defines.direction.west}
    -- loader.rotatable = false
    -- protected(chest)
    -- protected(loader)
    -- global.ttsfn.players[player.name].chests.stone = chest
    -- force.add_chart_tag(surface, {icon={type="item", name="stone"}, text="Stone output chest", target=chest, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}})

    -- --Wood
    -- offset = 5
    -- chest = surface.create_entity{name="logistic-chest-passive-provider", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}    
    -- loader = surface.create_entity{name="express-loader", type="output", force=game.forces.player, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}, direction=defines.direction.west}
    -- loader.rotatable = false
    -- protected(chest)
    -- protected(loader)
    -- global.ttsfn.players[player.name].chests["raw-wood"] = chest
    -- force.add_chart_tag(surface, {icon={type="item", name="raw-wood"}, text="Wood output chest", target=chest, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}})

    -- --Coal
    -- offset = 7
    -- chest = surface.create_entity{name="logistic-chest-passive-provider", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}    
    -- loader = surface.create_entity{name="express-loader", type="output", force=game.forces.player, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}, direction=defines.direction.west}
    -- loader.rotatable = false
    -- protected(chest)
    -- protected(loader)
    -- global.ttsfn.players[player.name].chests.coal = chest
    -- force.add_chart_tag(surface, {icon={type="item", name="coal"}, text="Coal output chest", target=chest, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}})

    -- --iron-ore
    -- offset = 9
    -- chest = surface.create_entity{name="logistic-chest-passive-provider", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}    
    -- loader = surface.create_entity{name="express-loader", type="output", force=game.forces.player, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}, direction=defines.direction.west}
    -- loader.rotatable = false
    -- protected(chest)
    -- protected(loader)
    -- global.ttsfn.players[player.name].chests["iron-ore"] = chest
    -- force.add_chart_tag(surface, {icon={type="item", name="iron-ore"}, text="Iron ore output chest", target=chest, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}})

    -- --copper-ore
    -- offset = 11
    -- chest = surface.create_entity{name="logistic-chest-passive-provider", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}    
    -- loader = surface.create_entity{name="express-loader", type="output", force=game.forces.player, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}, direction=defines.direction.west}
    -- loader.rotatable = false
    -- protected(chest)
    -- protected(loader)
    -- global.ttsfn.players[player.name].chests["copper-ore"] = chest
    -- force.add_chart_tag(surface, {icon={type="item", name="copper-ore"}, text="Copper ore output chest", target=chest, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}})

    -- --uranium-ore
    -- offset = 15
    -- chest = surface.create_entity{name="logistic-chest-passive-provider", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}    
    -- loader = surface.create_entity{name="express-loader", type="output", force=game.forces.player, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}, direction=defines.direction.west}
    -- loader.rotatable = false
    -- protected(chest)
    -- protected(loader)
    -- global.ttsfn.players[player.name].chests["uranium-ore"] = chest
    -- force.add_chart_tag(surface, {icon={type="item", name="uranium-ore"}, text="Copper ore output chest", target=chest, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}})


    --Upgrade-chest
    offset = 17
    chest = surface.create_entity{name="logistic-chest-requester", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}    
    protected(chest)
    global.ttsfn.players[player.name].chests.upgrade = chest
    local chunkx, chunky = math.floor(chest.position.x/32), math.floor(chest.position.y/32)
    ttsfn.metatable(global.ttsfn.delayed_chart, surface.index, chunkx, chunky)
    table.insert(global.ttsfn.delayed_chart[surface.index][chunkx][chunky], {icon={type="item", name="tank"}, text="Upgrade chest", target=chest, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}})

    --Drivetrain
    -- offset = 20
    -- local drivetrain = surface.create_entity{name="electric-energy-interface", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}
    -- protected(drivetrain)
    -- drivetrain.operable = false
    -- drivetrain.power_production = 0
    -- drivetrain.power_usage = 0
    -- global.ttsfn.players[player.name].drivetrain = drivetrain
    -- local chunkx, chunky = math.floor(drivetrain.position.x/32), math.floor(drivetrain.position.y/32)
    -- ttsfn.metatable(global.ttsfn.delayed_chart, surface.index, chunkx, chunky)
    -- table.insert(global.ttsfn.delayed_chart[surface.index][chunkx][chunky], {icon={type="item", name="electric-energy-interface"}, text="Drivetrain", target=drivetrain, position = {start_x-3, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}})

    --Mining drill
    offset = 20
    local mining_drill = surface.create_entity{name="electric-energy-interface", force=game.forces.player, position = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + offset}}
    protected(mining_drill)
    mining_drill.operable = false
    mining_drill.power_production = 0
    mining_drill.power_usage = 0
    global.ttsfn.players[player.name].mining_power = ttsfn.MINING_POWER
    mining_drill.electric_buffer_size = global.ttsfn.players[player.name].mining_power * 90000 * 100 --100s of power
    mining_drill.energy = mining_drill.electric_buffer_size
    global.ttsfn.players[player.name].mining_drill = mining_drill
    local chunkx, chunky = math.floor(mining_drill.position.x/32), math.floor((mining_drill.position.y+12)/32)
    ttsfn.metatable(global.ttsfn.delayed_chart, surface.index, chunkx, chunky)
    table.insert(global.ttsfn.delayed_chart[surface.index][chunkx][chunky], {icon={type="item", name="electric-energy-interface"}, text="Mining-Drill power", target=mining_drill, position = {mining_drill.position.x, mining_drill.position.y+12}})

    --Initialize variables.
    global.ttsfn.players[player.name].auto_turn = 0
    global.ttsfn.players[player.name].pos = {start_x-2, start_y + ttsfn.surface.START_HEIGHT / 2 + 6}
    global.ttsfn.players[player.name].speed = 0.15
    global.ttsfn.players[player.name].mining_power = ttsfn.MINING_POWER

    --Create map tags for information.

end

function ttsfn.nom(event)
    if not (event.entity and event.entity.valid and event.entity.type == "tree") then return end
    local tank = event.entity.surface.find_entities_filtered{name="tank", limit=1, area={{event.entity.position.x-2, event.entity.position.y-2}, {event.entity.position.x+2, event.entity.position.y+2}} }[1]
    if tank and tank.valid then
        --Find the matching tank and inser into it's wood chest.
        for k,v in pairs(global.ttsfn.players) do
            if v.tank and v.tank.valid and v.tank == tank then
                v.chests["raw-wood"].insert({name="raw-wood", count=4})
                --tank.insert({name="raw-wood", count=4})
            end
        end
    end
end

function ttsfn.upgrade(player)
    --Consume inputs from upgrade chest and improve related stats.

    --Electric drills -> Boost mining power, drivetrain power draw
    if global.ttsfn.players[player.name].chests.upgrade.get_item_count("electric-mining-drill") >= 1 then
        global.ttsfn.players[player.name].mining_power =
            (global.ttsfn.players[player.name].mining_power ^ 2
            + global.ttsfn.players[player.name].chests.upgrade.get_item_count("electric-mining-drill") ) ^ 0.5
        global.ttsfn.players[player.name].mining_drill.electric_buffer_size = global.ttsfn.players[player.name].mining_power * 90000 * 100
        global.ttsfn.players[player.name].chests.upgrade.remove_item{name="electric-mining-drill", count=100000}
    end

    --Locomotives -> Boost max speed, drivetrain power draw
    if global.ttsfn.players[player.name].chests.upgrade.get_item_count("locomotive") >= 1 then
        global.ttsfn.players[player.name].speed =
            (global.ttsfn.players[player.name].speed ^ 4
            + global.ttsfn.players[player.name].chests.upgrade.get_item_count("locomotive") ) ^ 0.25
        global.ttsfn.players[player.name].chests.upgrade.remove_item{name="locomotive", count=100000}
    end

    --Cargo wagons -> boost inside size.
    while global.ttsfn.players[player.name].chests.upgrade.get_item_count("cargo-wagon") >= 8 do
        ttsfn.expand(player) --This deducts wagons for us.
    end

    --Tanks -> Boost turret compartment size

    --Heavy armor -> Boost max HP
    if global.ttsfn.players[player.name].chests.upgrade.get_item_count("heavy-armor") >= 1 then
        local gains = global.ttsfn.players[player.name].chests.upgrade.get_item_count("heavy-armor")
        global.ttsfn.players[player.name].max_hp = global.ttsfn.players[player.name].max_hp + gains
        global.ttsfn.players[player.name].hp = global.ttsfn.players[player.name].hp + gains

        global.ttsfn.players[player.name].chests.upgrade.remove_item{name="heavy-armor", count=100000}
    end

    --Repair the tank.  Since we're looking at this thing.
    local hp_needed = global.ttsfn.players[player.name].max_hp - global.ttsfn.players[player.name].hp
    while global.ttsfn.players[player.name].chests.upgrade.get_item_count("repair-pack") > 0 and hp_needed > 500 do
        local stack = global.ttsfn.players[player.name].chests.upgrade.get_inventory(defines.inventory.chest).find_item_stack("repair-pack")
        stack.count = stack.count - 1
        global.ttsfn.players[player.name].hp = global.ttsfn.players[player.name].hp + 500
        hp_needed = global.ttsfn.players[player.name].max_hp - global.ttsfn.players[player.name].hp
    end
    -- if global.ttsfn.players[player.name].chests.upgrade.get_item_count("repair-pack") >= 1 then
    --     local hp_needed = global.ttsfn.players[player.name].tank.max_hp - global.ttsfn.players[player.name].tank.hp
    --     local hp_per_pack = 500
    --     local stack = global.ttsfn.players[player.name].chests.upgrade.find_item_stack("repair-pack")
    --     while hp_needed > 500 and stack.count > 1 do
    --         local restored = stack.durability / stack.prototype.durability * hp_per_pack
    --         stack.count = stack.count - 1
    --         global.ttsfn.players[player.name].tank.hp = global.ttsfn.players[player.name].tank.hp + restored
    --         hp_needed = global.ttsfn.players[player.name].tank.max_hp - global.ttsfn.players[player.name].tank.hp
    --     end
    --     if hp_needed > 0 and (stack.count > 1 or stack.durability > stack.prototype.durability / hp_per_pack) then
    --         local restored = math.min(stack.durability / stack.prototype.durability * hp_per_stack, hp_needed )
    --         if restored == hp_needed then
    --             stack.duability = stack.durability - restored / hp_per_stack
    --         else
    --             stack.count = stack.count - 1
    --         end
    --         global.ttsfn.players[player.name].tank.hp = global.ttsfn.players[player.name].tank.max_hp
    --     end
    -- end
end

function ttsfn.expand(player)
    --Deduct 1 cargo wagon per 8 tiles.
    global.ttsfn.players[player.name].chests.upgrade.remove_item{name="cargo-wagon", count=8}

    global.ttsfn.players[player.name].end_x = global.ttsfn.players[player.name].end_x - 1
    local start_y = (player.index) * (ttsfn.surface.MARGIN + ttsfn.surface.HEIGHT)
    local end_x = global.ttsfn.players[player.name].end_x
    local tiles = {}
    for y = start_y, start_y + ttsfn.surface.START_HEIGHT - 1 do
        table.insert(tiles, {name="concrete", hidden_tile="brick", position={end_x, y}})
    end
    game.surfaces.ttsfn.set_tiles(tiles)

end

--Gui create
function ttsfn.driving_gui(player)
    if player.gui.top["ttsfn-driving"] then return end --Somehow this got called twice.
    local pane = player.gui.top.add{type="frame", name="ttsfn-driving", direction="vertical"}
    pane.add{type="button", name="ttsfn-enter", caption="Inside"}
    pane.add{type="button", name="ttsfn-stats", caption="Stats"}
    pane.add{type="checkbox", name="ttsfn-open", caption="Accept Crew", state=false}
    local turn = pane.add{type="flow", direction="horizontal", name="turn"}
    turn.add{type="slider", name="ttsfn-autoturn", orientation="horizontal", caption="Auto-turn", minimum_value=-0.0005, maximum_value=0.0005}
    turn.add{type="checkbox", name="ttsfn-windvane", caption="Random", state=false}
    local flow = pane.add{type="flow", direction="horizontal", name="hpflow"}
    flow.add{type="label", name="label", caption="HP: "}
    local hp = flow.add{type="label", name="hp", caption=math.ceil(global.ttsfn.players[player.name].hp)}
    flow.add{type="label", name="div", caption = "/"}
    flow.add{type="label", name="max_hp", caption=global.ttsfn.players[player.name].max_hp}
    hp.style.font_color = ttsfn.health_color(global.ttsfn.players[player.name].hp/global.ttsfn.players[player.name].max_hp)
end

function ttsfn.inside_gui(player)
    if player.gui.top["ttsfn-inside"] then return end
    local pane = player.gui.top.add{type="frame", name="ttsfn-inside", direction="vertical"}
    pane.add{type="button", name="ttsfn-drive", caption="Drive"}
    pane.add{type="button", name="ttsfn-stats", caption="Stats"}

    local flow = pane.add{type="flow", direction="horizontal", name="hpflow"}
    flow.add{type="label", name="label", caption="HP: "}
    local hp = flow.add{type="label", name="hp", caption=math.ceil(global.ttsfn.players[player.name].hp)}
    flow.add{type="label", name="div", caption = "/"}
    flow.add{type="label", name="max_hp", caption=global.ttsfn.players[player.name].max_hp}
    hp.style.font_color = ttsfn.health_color(global.ttsfn.players[player.name].hp/global.ttsfn.players[player.name].max_hp)
    -- hp.style.font = "default-game"
    -- hp.style.minimal_width = 160
end

--Stats!
--Display info like speed (current, max)
function ttsfn.stats(player)
    if player.gui.top["ttsfn-stats"] then
        player.gui.top["ttsfn-stats"].destroy()
        return
    end
    local pane = player.gui.top.add{type="frame", name="ttsfn-stats", direction="vertical"}
    local gui_table = pane.add{ type = "table", name = "stats_table", column_count = 3 }
    --Headers
    gui_table.add{type="label"}
    gui_table.add{type="label", caption="Stat"}
    gui_table.add{type="label", caption="Upgrades With"}
    
    --Speed
    --local flow = pane.add{type="flow", direction="horizontal", name="speedflow"}
    gui_table.add{type="label", name="speedheader", caption="Speed:"}
    gui_table.add{type="label", name="speed", caption=global.ttsfn.players[player.name].speed * 3.6 * 60 .. "km/h"}
    gui_table.add{type="sprite", sprite="item/locomotive"}

    --Mining power
    gui_table.add{type="label", name="miningheader", caption="Mining:"}
    gui_table.add{type="label", name="mining", caption=global.ttsfn.players[player.name].mining_power}
    gui_table.add{type="sprite", sprite="item/electric-mining-drill"}

    --max_hp
    gui_table.add{type="label", name="hpheader", caption="Max HP:"}
    gui_table.add{type="label", name="maxhp", caption=global.ttsfn.players[player.name].max_hp}
    gui_table.add{type="sprite", sprite="item/heavy-armor"}

    --size
    gui_table.add{type="label", name="sizeheader", caption="Size:"}
    gui_table.add{type="label", name="size", caption=-global.ttsfn.players[player.name].end_x}
    gui_table.add{type="sprite", sprite="item/cargo-wagon"}
end

function ttsfn.update_hp(player)
    local pane = player.gui.top["ttsfn-inside"] or player.gui.top["ttsfn-driving"]
    if not pane then return end
    -- TODO: Make sure this tank crew members get their parent tank.
    local hp_elem = pane.hpflow.hp
    local max_hp_elem = pane.hpflow.max_hp
    local hp = math.ceil(global.ttsfn.players[player.name].hp)
    local max_hp = math.ceil(global.ttsfn.players[player.name].max_hp)
    hp_elem.caption = hp
    max_hp_elem.caption = max_hp
end

--Gui control functions.
function ttsfn.gui_click(event)
    if not (event.element and event.element.valid) then return end
    local player = game.players[event.player_index]
    if event.element.name == "ttsfn-enter" then
        event.element.parent.destroy()
        ttsfn.inside_gui(player)
        player.teleport(global.ttsfn.players[player.name].pos, "ttsfn")
        return
    end

    if event.element.name == "ttsfn-drive" then
        ttsfn.driving_gui(player)
        event.element.parent.destroy()
        global.ttsfn.players[player.name].pos = player.position
        player.teleport({0,0}, "nauvis")
        if not global.ttsfn.players[player.name].tank.get_driver() then
            global.ttsfn.players[player.name].tank.set_driver(player)
        else
            player.print("Driver seat is occupied")
        end

        return
    end

    if event.element and event.element.name == "ttsfn-stats" then
        ttsfn.stats(player)
    end

end

function ttsfn.health_color(float)
    return { r = math.min(1, 1-float),
        g = math.max(0, float),
        b = 0
    }
end

function ttsfn.auto_turn(event)
    if not (event.element and event.element.valid) then return end
    if not event.element.name == "ttsfn-autoturn" then return end

    local player = game.players[event.player_index]
    global.ttsfn.players[player.name].auto_turn = event.element.slider_value

end

function ttsfn.windvane(event)
    if not (event.element and event.element.valid) then return end
    if not event.element.name == "ttsfn-windvane" then return end
    local player = game.players[event.player_index]
    global.ttsfn.players[player.name].windvane = event.element.state

    event.element.parent["ttsfn-autoturn"].enabled = not event.element.state
end

function ttsfn.delayed_chart_tag(event)
    if global.ttsfn.delayed_chart[event.surface_index] and global.ttsfn.delayed_chart[event.surface_index][event.position.x] and global.ttsfn.delayed_chart[event.surface_index][event.position.x][event.position.y] then
        for k,v in pairs(global.ttsfn.delayed_chart[event.surface_index][event.position.x][event.position.y]) do
            event.force.add_chart_tag(game.surfaces[event.surface_index], v )
        end
        global.ttsfn.delayed_chart[event.surface_index][event.position.x][event.position.y] = nil
        if #global.ttsfn.delayed_chart[event.surface_index][event.position.x] == 0 then
            global.ttsfn.delayed_chart[event.surface_index][event.position.x] = nil
        end
    end
end

--If value at index does not exist, create it.
function ttsfn.metatable(table, index, x, y)
    if not table[index][x] then
        table[index][x] = {}
    end
    if not table[index][x][y] then
        table[index][x][y] = {}
    end
end

--Create the TTSFN surface
function ttsfn.on_init()
    --The initial 3x3 area should never be used.  But we can't specify 0 height and width.
    --local surface = game.create_surface("ttsfn", {width=1, height=1})
    local surface = game.create_surface("ttsfn")
    global.ttsfn.delayed_chart[surface.index] = {}
    --Suppress normal terrain generation.  Map exclusively uses the third quadrant.
    for x = -50, 20 do
        for y = -20, 50 do
            surface.set_chunk_generated_status({x,y}, defines.chunk_generated_status.entities)
        end
    end

    --Need to chart the surface so map tags can be drawn.
    --game.forces.player.chart_all(surface)
    game.forces.player.chart(surface, {{-320, -320}, {320, 320}})

    surface.daytime = 0.5
    surface.freeze_daytime = true

    game.forces.enemy.evolution_factor = 0.4
    --For some reason this doesn't work.
    -- for x = -1, 1 do
    --     for y = -1, 1 do
    --         surface.set_tiles{{name="out-of-map", position={x,y}}}
    --     end
    -- end
    --Default permissions does not enable leaving the vehicle!
    local perms = game.permissions.groups[1]
    perms.set_allows_action(defines.input_action.toggle_driving, false)
end

--TODO: Check for low HP to interrupt death and use custom HP
Event.register(defines.events.on_gui_checked_state_changed, ttsfn.windvane)
Event.register(defines.events.on_gui_value_changed, ttsfn.auto_turn)
Event.register(defines.events.on_entity_died, ttsfn.nom)
Event.register(defines.events.on_gui_click, ttsfn.gui_click)
Event.register(defines.events.on_tick, ttsfn.drive)
Event.register(defines.events.on_player_created, ttsfn.create_player)
Event.register(defines.events.on_chunk_charted, ttsfn.delayed_chart_tag)
Event.register(-1, ttsfn.on_init)