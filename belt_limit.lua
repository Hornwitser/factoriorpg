if MODULE_LIST then
	module_list_add("Belt Limiter")
end


belter = {}
belter.LIMIT = 2000

global.belt_limit = {}

function belter.build(event)
    if not (event.created_entity and event.created_entity.valid and event.created_entity.last_user) then
        return
    end
    if not (event.created_entity.type == "transport-belt" or event.created_entity.type == "underground-belt" or event.created_entity.type == "splitter") then
        return
    end
    if not global.belt_limit[event.created_entity.last_user.name] then
        global.belt_limit[event.created_entity.last_user.name] = belter.LIMIT
    end
    if global.belt_limit[event.created_entity.last_user.name] <= 0 then
        event.created_entity.active = false
        event.created_entity.last_user.print("No more belts remaining.")
    else
        global.belt_limit[event.created_entity.last_user.name] = global.belt_limit[event.created_entity.last_user.name] - 1
        belter.notify(event.created_entity.last_user)
    end
end

function belter.died(event)
    if not (event.entity and event.entity.valid and event.entity.last_user) then
        return
    end
    if not (event.entity.type == "transport-belt" or event.entity.type == "underground-belt" or event.entity.type == "splitter") then
        return
    end
    if not global.belt_limit[event.entity.last_user.name] then
        --How did we get here?
        return
    end
    if global.belt_limit[event.entity.last_user.name] < 2000 then
        global.belt_limit[event.entity.last_user.name] = global.belt_limit[event.entity.last_user.name] + 1
        belter.notify(event.entity.last_user)
    else
        --How did we get here?
        return
    end
end

function belter.notify(player)
    if global.belt_limit[player.name] % 100 == 0 then
        player.print(global.belt_limit[player.name] .. " belts remaining")
    end
end

Event.register(defines.events.on_entity_died, belter.died)
Event.register(defines.events.on_player_mined_entity, belter.died)
Event.register(defines.events.on_robot_mined_entity, belter.died)
Event.register(defines.events.on_built_entity, belter.build)
Event.register(defines.events.on_built_entity, belter.build)
Event.register(defines.events.on_robot_built_entity, belter.build)