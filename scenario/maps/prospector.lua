-- Prospector, have to search for ores via prospecting
-- Written by Mylon, 2018
-- MIT license

if MODULE_LIST then
	module_list_add("Prospector")
end

global.prospector = 10
prospector = {STARTING_RADIUS = 150, DISTANCE_POWER = 0.75, DISTANCE_FACTOR = 0.125, SCAN_COUNT_FACTOR = 0.01, BITER_FACTOR = 0.08,
BITER_SCAN_RADIUS=150, ORE_PENALTY = 0.001}
prospector.ore_types = {
    "coal",
    "coal",
    "stone",
    "stone",
    "iron-ore",
    "iron-ore",
    "iron-ore",
    "iron-ore",
    "iron-ore",
    "iron-ore",
    "copper-ore",
    "copper-ore",
    "copper-ore",
    "copper-ore",
    "uranium-ore"
}

function prospector.add_ore(event)
    --Before we do anything, increment the ore found counter.
    global.prospector = global.prospector + prospector.SCAN_COUNT_FACTOR

    local x, y = event.chunk_position.x * 32 + math.random(0, 31), event.chunk_position.y * 32 + math.random(0, 31)
    local surface = event.radar.surface
    local tile = surface.get_tile(x, y)
    if tile.collides_with("water-tile") then
        --Find fallback position.
        local pos = surface.find_non_colliding_position("iron-ore", {event.chunk_position.x+15, event.chunk_position.y+15}, 16, 1)
        if pos then
            x, y = pos.x, pos.y
        else
            return --Fallback failed.
        end

    end

    local area = {{x - prospector.BITER_SCAN_RADIUS, y-prospector.BITER_SCAN_RADIUS}, {x+prospector.BITER_SCAN_RADIUS, y+prospector.BITER_SCAN_RADIUS}}
    local biter_count = surface.count_entities_filtered{type="unit-spawner", area=area}
    local ore_count = surface.count_entities_filtered{type="resource", area=area}
    --Some fancy math here.
    local amount = (biter_count * prospector.BITER_FACTOR * global.prospector) * (1- ore_count * prospector.ORE_PENALTY)
    -----------------------
    local ore_type = prospector.ore_types[math.random(1, #prospector.ore_types)]
    if amount > 1 then
        surface.create_entity{name=ore_type, position={x,y}, amount=amount, enable_cliff_removal=false}
    else
        return
    end

    --Now wake up miners if they're already present.
    local radius = 2
    local miners = surface.find_entities_filtered{type="mining-drill", area={{x-radius, y-radius}, {x+radius, y+radius}}}
    for k,v in pairs(miners) do
        v.active = false
        v.active = true
    end
    
end

--Kill ores not in the starting area
function prospector.nom(event)
    local oldores = event.surface.find_entities_filtered{type="resource", area=event.area}
    for k, v in pairs(oldores) do
        if ((v.position.x^2 + v.position.y^2) > prospector.STARTING_RADIUS ^2) and v.prototype.resource_category == "basic-solid" then
            v.destroy()
        end
    end
end

Event.register(defines.events.on_sector_scanned, prospector.add_ore)
Event.register(defines.events.on_chunk_generated, prospector.nom)