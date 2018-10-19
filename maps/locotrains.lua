--Loco Trains
-- By Mylon, 2017
-- MIT License

--Notes:
--Positions are always odd.  
--A corner is 2 curved-rail joined by a straight-rail.
--For a bottom-left corner, the top rail "faces" west, curve inbetween faces SW, and the bottom one faces northwest,
--For bottomleft corner, NW rail is position 0,0, first curve is 1, 5, straight rail is 4, 8, second curve is 7, 11, SE rail is 12, 12
--SE corner (from bottom-left): facing: E, NE, S

if MODULE_LIST then
	module_list_add("Loco Trains")
end

--If train is stopped or dies, bad stuff happens.
function test_loco(event)
    if not (event.entity and event.entity.valid) then
        return
    end
    if not event.entity.name == "locomotive" and event.entity.force.name = "loco" then
        return
    end
    --We're still here?  Boom!
    go_loco(event.entity)
    --Small nicks and dings can be overcome...
end

function go_loco(entity)
    entity.surface.create_entity{name="atomic-rocket", target=entity, speed=20}
end

-- Draw rails
function draw_locos(event)
    --Each corner function is anchored by the position of the last straight-rail on the NW or SW corner.  Each corner function is named by where it would be on a square.
    --Based on NW corner


    --Trains only move counter-clockwise because they're dirty commies.
    --Let's draw growing rectangles of alternating length.  Each rectangle intersects with the previous and next one.
    

end

function loose_wheel(event)
    if not (event.tick % (60*60) == 0) then
        return
    end

    for k, v in pairs(game.forces.enemy.get_trains("1")) do
        if v.train_state == defines.train_state.no_path then
            --Uh oh.
            for n, p in pairs(v.locomotives) do
                p.health = p.health - 500 --4 minutes of warning
            end
        else
            for n, p in pairs(v.locomotives) do
                p.health = p.health + 2 --Heal small nicks and dings.
            end
        end
    end
end

function draw_SW_corner(position)
    local surface = game.surfaces[1]
    surface.create_entity{name="curved-rail", position={position.x+1, position.y+5}, force=game.forces.enemy, direction=defines.direction.south}
    surface.create_entity{name="straight-rail", position={position.x+4, position.y+8}, force=game.forces.enemy, direction=defines.direction.southwest}
    surface.create_entity{name="curved-rail", position={position.x+7, position.y+11}, force=game.forces.enemy, direction=defines.direction.northwest}
end
--Based on SW corner position
function draw_SE_corner(position)
    local surface = game.surfaces[1]
    surface.create_entity{name="curved-rail", position={position.x+5, position.y-1}, force=game.forces.enemy, direction=defines.direction.east}
    surface.create_entity{name="straight-rail", position={position.x+8, position.y-4}, force=game.forces.enemy, direction=defines.direction.southeast}
    surface.create_entity{name="curved-rail", position={position.x+11, position.y-7}, force=game.forces.enemy, direction=defines.direction.southwest}
end
--Based on SW corner position
function draw_NW_corner(position)
    local surface = game.surfaces[1]
    surface.create_entity{name="curved-rail", position={position.x+1, position.y-5}, force=game.forces.enemy, direction=defines.direction.northeast}
    surface.create_entity{name="straight-rail", position={position.x+4, position.y-8}, force=game.forces.enemy, direction=defines.direction.northwest}
    surface.create_entity{name="curved-rail", position={position.x+7, position.y-11}, force=game.forces.enemy, direction=defines.direction.west}
end
--Based on NW corner position
function draw_NE_corner(position)
    local surface = game.surfaces[1]
    surface.create_entity{name="curved-rail", position={position.x+5, position.y+1}, force=game.forces.enemy, direction=defines.direction.southeast}
    surface.create_entity{name="straight-rail", position={position.x+8, position.y+4}, force=game.forces.enemy, direction=defines.direction.northeast}
    surface.create_entity{name="curved-rail", position={position.x+11, position.y+7}, force=game.forces.enemy, direction=defines.direction.north}
end

function draw_straight(position1, position2)
    local surface = game.surfaces[1]
    --North/south line
    if position1.x == position2.x then
        local direction = 2 --Going south
        if position1.y > position2.y then
            direction = -2 --Going north
        end
        for y = position1.y, position2.y, direction do
            surface.create_entity{name="straight-rail", position={position1.x, y}, force=game.forces.enemy, direction=defines.direction.north}
        end
        if 
        surface.create_entity{name="rail-signal", position={position1.x+1, position1.y}, direction=defines.direction.south}
        surface.create_entity{name="rail-signal", position={position1.x-2, position1.y}, direction=defines.direction.north}
        surface.create_entity{name="rail-signal", position={position1.x+1, position2.y}, direction=defines.direction.south}
        surface.create_entity{name="rail-signal", position={position1.x-2, position2.y}, direction=defines.direction.south}
end

function loco_init()
    global.track_generated={}
    --We'll draw the first rectangle manually.

end

Event.register(-1, loco_init)
Event.register(defines.events.on_tick, loose_wheel)
Event.register(defines.events.on_entity_died, test_loco)
Event.register(defines.events.on_chunk_generated, draw_locos)