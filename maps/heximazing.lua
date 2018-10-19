
if MODULE_LIST then
	module_list_add("Hexi's Maze")
end

hexi = {}

function hexi.init()
    game.forces.player.technologies["logistic-system"].enabled = false --This doesn't actually work... Class changing re-enables it.
end

function hexi.nologistics()
    if not (event.research and event.research.valid) then
        return
    end
    if event.research.name == "logistic-system" then
        event.research.force.current_research=nil
        event.research.enabled = false
    end
end

--Radars cannot scan.  They only reveal the nearby area.
function hexi.unscan(event)
    if not (event and event.entity and event.entity.valid) then
        return
    end
    event.entity.force.unchart_chunk(event.chunk_position, event.entity.surface)
end

function hexi.radars(event)
    if event.created_entity and event.created_entity.valid and event.created_entity.name == "radar" then
        --Radar range is 14 chunks.
        local radar = event.created_entity
        local chunkx = math.floor(radar.position.x / 32)
        local chunky = math.floor(radar.position.y / 32)
        for x = chunkx - 14, chunkx + 14 do
            for y = chunky - 14, chunky + 14 do
                if not radar.force.is_chunk_charted(radar.surface, {x, y}) then
                    radar.surface.create_entity{name="item-on-ground", stack={name="radar"}, position=radar.position}
                    local last_user = radar.last_user
                    if last_user then
                        last_user.print("Radars cannot be used to scout.")
                    end
                    radar.destroy()
                    return
                end
            end
        end
    end
end

--Event.register(-1, hexi.init)
Event.register(defines.events.on_built_entity, hexi.radars)
Event.register(defines.events.on_robot_built_entity, hexi.radars)
--Event.register(defines.events.on_research_started, hexi.nologistics)
--Event.register(defines.events.on_sector_scanned, hexi.unscan)
--Event.remove(defines.events.on_sector_scanned, rpg_bonus_scan)