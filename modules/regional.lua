--Regional production, goods can only be produced within certain regions
--Written by Mylon, 2018-10
--MIT License

if MODULE_LIST then
	module_list_add("Regional Production")
end

regional = {
    RANGE = 48,
    CHANCE = 40
}

global.regional = {registry = {}, index=1} --Duplicate

function regional.region(event)
    --First check if we're spawning one.
    if not (math.random(regional.CHANCE) == regional.CHANCE) then
        return
    end
    local choice = global.regional.categories[math.random(#global.regional.categories)]
    -- Old per-recipe method
    -- local count = 1
    -- local recipe
    -- for k,v in pairs(game.forces.player.recipes) do
    --     if count == choice then
    --         if v.hidden then --Don't show smelting recipes!
    --             break
    --         end
    --         recipe = game.forces.player.recipes[k]
    --         break
    --     end
    --     count = count + 1
    -- end
    -- if recipe then
    --     local signal = {type=recipe.products[1].type, name=recipe.products[1].name}
    --     local combinator = event.surface.create_entity{name="constant-combinator", force=game.forces.player, position={math.random(event.area.left_top.x, event.area.right_bottom.x), math.random(event.area.left_top.y, event.area.right_bottom.y)} }
    --     combinator.get_or_create_control_behavior().set_signal(1, {signal=signal, count=regional.RANGE})
    --     combinator.destructible = false
    --     combinator.operable = false
    --     combinator.minable = false
    -- end
    local combinator = event.surface.create_entity{name="constant-combinator", force=game.forces.player, position={math.random(event.area.left_top.x, event.area.right_bottom.x), math.random(event.area.left_top.y, event.area.right_bottom.y)} }
    local count = 1
    local maxcount = combinator.get_or_create_control_behavior().signals_count
    for _,r in pairs(global.regional.valid) do
        local v = game.forces.player.recipes[r]
        if v.subgroup == choice then
            local signal = {type = v.products[1].type, name=v.products[1].name}
            combinator.get_or_create_control_behavior().set_signal(count, {signal=signal, count=regional.RANGE})
            count = count + 1
            if count > maxcount then --Crash protection for v0.16
                break
            end
        end
    end
    combinator.destructible = false
    combinator.operable = false
    combinator.minable = false
    --Multiple may spawn!
    regional.region(event)

end

function regional.register(event)
    if not(event.created_entity.type == "assembling-machine" or event.created_entity.type == "furnace" or event.created_entity.type == "lab") then
        return
    end
    table.insert(global.regional.registry, event.created_entity)
end

function regional.checker(event)
    -- Iterate over 30 entities
    for i = 0, 29 do
        --if #global.regional.registry == 0 or i >= #global.regional.registry then
        if i >= #global.regional.registry then
            return
        end
        if global.regional.index + i > #global.regional.registry then
            global.regional.index = 1
        end
        local entity = global.regional.registry[global.regional.index + i]
        if entity.valid then
            --Check if this was a lab or a furnace, these only need to be checked once ever.
            local special = regional.enforcement(entity)
            if special then
                table.remove(global.regional.registry, global.regional.index + i)
            end
        else
            table.remove(global.regional.registry, global.regional.index + i)
        end
        global.regional.index = global.regional.index + 1
    end
end

function regional.enforcement(entity)
    local area = {{entity.position.x - regional.RANGE, entity.position.y - regional.RANGE}, {entity.position.x + regional.RANGE, entity.position.y + regional.RANGE}}
    local regions = entity.surface.find_entities_filtered{type="constant-combinator", area=area}
    local allowed = {}

    --Special rule for labs
    if entity.type == "lab" then
        return true
    end

    for k,v in pairs(regions) do
        if v.operable == false then
            local signal = v.get_control_behavior().get_signal(1)
            if not signal then
                log("Error, no signal found!")
                return
            end
            table.insert(allowed, {position = v.position, recipe=v.get_control_behavior().get_signal(1).signal.name, subgroup = game.forces.player.recipes[v.get_control_behavior().get_signal(1).signal.name].subgroup} )
        end
    end
    for k,v in pairs(allowed) do
        --Furnaces
        if regional.get_range_squared(entity.position, v.position) < regional.RANGE^2 then
            if entity.type == "furnace" and v.subgroup.name == "raw-material" then
                return true
            end
            local recipe = entity.get_recipe()
            if recipe and recipe.subgroup == v.subgroup then
                return
            end
        end
    end
    --Still here?  Shut it down!
    if entity.get_recipe() then
        regional.notify(entity)
    end
    if entity.type == "furnace" then --Can't set_recipe on a furnace, 
        entity.active = false
        entity.order_deconstruction(entity.force)
        return true
    end
    entity.set_recipe(nil)
end

--Old method per recipe basis
-- function regional.enforcement(entity)
--     local area = {{entity.position.x - regional.RANGE, entity.position.y - regional.RANGE}, {entity.position.x + regional.RANGE, entity.position.y + regional.RANGE}}
--     local regions = entity.surface.find_entities_filtered{type="constant-combinator", area=area}
--     local allowed = {}
--     for k,v in pairs(regions) do
--         if v.operable == false then
--             table.insert(allowed, {position = v.position, recipe=v.get_control_behavior().get_signal(1).signal.name})
--         end
--     end
--     for k,v in pairs(allowed) do
--         local recipe = entity.get_recipe()
--         if recipe and recipe.products[1].name == v.recipe and regional.get_range_squared(entity.position, v.position) < regional.RANGE^2 then
--             return
--         end
--     end
--     --Still here?  Shut it down!
--     entity.set_recipe(nil)
-- end

function regional.discovered(event)
    local force = event.force
    local area = {{event.position.x * 32, event.position.y * 32}, {(event.position.x + 1) * 32, (event.position.y + 1) * 32}}
    local surface = game.surfaces[event.surface_index]
    local regions = surface.find_entities_filtered{type="constant-combinator", area=area}
    for k,v in pairs(regions) do
        if v.operable == false then
            --log("Adding chart tag")
            local signal = v.get_control_behavior().get_signal(1).signal
            local tags = force.find_chart_tags(surface, area)
            local discovered = false
            for __,tag in pairs(tags) do
                if tag.icon.name == signal.name then
                    discovered = true
                    break
                end
            end
            if not discovered then
                force.add_chart_tag(surface, {position = v.position, icon=signal} )
            end
            --force.add_chart_tag(game.surfaces[event.surface_index], {position = v.position, text=signal.name} )
        end
    end
end

function regional.init()
    global.regional = {registry = {}, index=1, valid = {}, categories = {}, cat_size = 0}

    -- Build a list of recipes with techs that unlock them
    local valid = {}
    for k,v in pairs(game.forces.player.recipes) do
        if v.enabled then
            table.insert(valid, v.name)
        end
    end
    for _,v in pairs(game.forces.player.technologies) do
        for __,e in pairs(v.effects) do
            if e.type == "unlock-recipe" then
                table.insert(valid, e.recipe)
            end
        end
    end
    global.regional.valid = valid

    -- Build a list of categories based on global.regional.valid
    -- This uses the first found recipe for a given category.
    for k,v in pairs(global.regional.valid) do
        local subgroup = game.forces.player.recipes[v].subgroup
        if not global.regional.categories[subgroup] then
            table.insert(global.regional.categories, subgroup) --Will have duplicates based on number of number of occurences.  Should bias region generation.
        end
    end

    --Guarantee a smelting beacon near the start
    local combinator = game.surfaces[1].create_entity{name="constant-combinator", force=game.forces.player, position={math.random(-96, 96), math.random(-96, 96)} }
    local choice = game.forces.player.recipes["iron-plate"].subgroup
    local count = 1
    local maxcount = combinator.get_or_create_control_behavior().signals_count
    --local choice = nil
    for k,v in pairs(game.forces.player.recipes) do
        if v.subgroup == choice then
            local signal = {type = v.products[1].type, name=v.products[1].name}
            combinator.get_or_create_control_behavior().set_signal(count, {signal=signal, count=regional.RANGE})
            count = count + 1
            if count > maxcount then --Crash protection for v0.16
                break
            end
        end
    end
    combinator.destructible = false
    combinator.operable = false
    combinator.minable = false

end

function regional.notify(entity)
    if not entity.last_user then return end
    entity.last_user.print("Recipes must be within a matching region!")
end

function regional.get_range_squared(pos1, pos2)
    return (pos1.x - pos2.x)^2 + (pos1.y - pos2.y)
end

Event.register(defines.events.on_chunk_generated, regional.region)
Event.register(defines.events.on_built_entity, regional.register)
Event.register(defines.events.on_robot_built_entity, regional.register)
Event.register(defines.events.on_chunk_charted, regional.discovered)
Event.register(-1, regional.init)
script.on_nth_tick(60, regional.checker)