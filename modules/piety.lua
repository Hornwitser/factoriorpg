--Piety, tribute to the god of industry
--Written by Mylon, 2017
--MIT License

if MODULE_LIST then
	module_list_add("Piety")
end

--global.pious = {}
piety = {}
piety.THRESHHOLD = 20000 --How much landfill must a loginet have to trigger?
piety.DIVISOR = 15 --Consume 1 / this landfill per event.
piety.SCATTER = false --Scatter roboport contents?
--piety.ORE_LIST = {"iron-ore", "copper-ore", "coal"} --This is the list of ores that landfill can spawn.  Need to replace this with an auto-generated list for mod compatability.
global.piety = {}

function piety.third_day(event)
    local surface = game.surfaces[event.surface_index]
    global.piety[surface.name] = {}
    for k,v in pairs(surface.map_gen_settings.autoplace_controls) do
        local prototype = game.entity_prototypes[k]
        if prototype and prototype.infinite_resource == false and prototype.resource_category == "basic-solid" and prototype.mineable_properties.required_fluid == nil then
            if k ~= "stone" then --Intended to block this from being a source of infinite ore, but this only really works in vanilla.
                table.insert(global.piety[surface.name], k)
            end
        end
    end
    --game.print("Piety: Surface created event parsed for index: " .. event.surface_index .. ", name: " .. surface.name)
end

--Nauvis never gets its surface-created event.
function piety.init()
    piety.third_day{surface_index=1}
end

function piety.tribute(event)
    --Check once per hour, offset by 7 minutes
    --if game.tick % 216000 ~= 25200 then
    --if game.tick % 600 ~= 0 then --Debug
    --     return
    -- end
    --Check all forces
    for _, force in pairs(game.forces) do
        if force and force.valid then            
            for surface_name, surface_list in pairs(force.logistic_networks) do
                for ___, network in pairs(surface_list) do
                    if network and network.valid then
                        --Check for overflow
                        if network.get_item_count("landfill") < 1500000000 and network.get_item_count("landfill") >= piety.THRESHHOLD then
                            --Pick a roboport at random.
                            local cell = network.cells[math.random(#network.cells)]
                            if cell and cell.valid and cell.owner and cell.owner.valid then
                                local miracle = cell.owner

                                --Find minimum in loginet of iron, coal, copper and grant that.
                                local least = {"iron-ore", 1000000000}
                                for k,v in pairs(global.piety[surface_name]) do
                                     if least[2] > network.get_item_count(v) then
                                        least[1], least[2] = v, network.get_item_count(v)
                                     end
                                end
                                --table.sort(ores)                                
                                local res = least[1]

                                --55% chance of iron, 30% chance of copper, 15% chance of coal
                                -- local res = "iron-ore"
                                -- local rand = math.random()
                                -- if rand < 0.15 then
                                --     res = "coal"
                                -- elseif rand < 0.45 then
                                --     res = "copper-ore"
                                -- end

                                local amount = math.floor(network.get_item_count("landfill") / piety.DIVISOR) * 20
                                --Landfill costs 20 stone, so the blessing should be 20x the amount of landfill taken.
                                
                                network.remove_item{name="landfill", count=amount}
                                --Check if dangOreus is active and turn off ghosts.
                                if dangOre then
                                    local ttl = force.ghost_time_to_live
                                    force.ghost_time_to_live = 0
                                    piety.scatter(cell.owner, amount)
                                    force.ghost_time_to_live = ttl
                                else
                                    piety.scatter(cell.owner, amount)
                                end
                                piety.bless(cell.owner.surface, cell.owner.position, res, amount)
                                if cell.owner.last_user then
                                    game.print(cell.owner.last_user.name .. " has been blessed by the god of industry.")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

--/c piety.bless(game.player.surface, game.player.selected.position, "iron-ore", 200000)
--This doesn't actuallge generate (amount) of resources, but close enough and it scales linearly.
--200k creates zone of amount 164k
function piety.bless(surface, position, resource, amount)
    local radius = math.floor(amount^0.244)
    for x = position.x - radius, position.x + radius do
        for y = position.y - radius, position.y + radius do
            local intensity = math.floor(radius^2 - (position.x - x)^2 - (position.y - y)^2)
            if intensity > 0 then
                local corrected_pos = surface.find_non_colliding_position(resource, {x,y}, 10, 1)
                if corrected_pos ~= nil then
                    surface.create_entity{name=resource, position=corrected_pos, amount=intensity, enable_tree_removal=false, enable_cliff_removal=false}
                end
            end
        end
    end
    --If any miners are present, wake them up!
    local miners = surface.find_entities_filtered{type="mining-drill", area={{position.x-radius, position.y-radius}, {position.x+radius, position.y+radius}}}
    for k,v in pairs(miners) do
        v.active = false
        v.active = true
    end
end

--Scatter the roboport's contents about and destroy it.
function piety.scatter(roboport, blessing)
    for i = 1, 3 do
        local inv = roboport.get_inventory(i)
        if inv then
            for n,p in pairs(inv.get_contents()) do
                if piety.SCATTER then
                    roboport.surface.spill_item_stack(roboport.position, {name=n, count=p})
                else
                    if n == "logistic-robot" then
                        blessing = blessing + 50 * p
                    elseif n == "construction-robot" then
                        blessing = blessing + 36 * p
                    elseif n == "repair-pack" then
                        blessing = blessing + 9 * p
                    end
                end
            end
        end
    end
    roboport.die()
end

Event.register(-1, piety.init)
Event.register(defines.events.on_surface_created, piety.third_day)
--Event.register(defines.events.on_tick, piety.tribute)
script.on_nth_tick(600, piety.tribute)

--if game.tick % 216000 ~= 25200 then
--if game.tick % 600 ~= 0 then --Debug