--Allows players to craft items in mass quantities.

pcraft = {}
global.pcraft = {}

function pcraft.add_gui(event)
    local player = game.players[event.player_index]
    if not mod_gui.get_button_flow(player)["pcraft"] then
		mod_gui.get_button_flow(player).add { name = "pcraft", type = "sprite-button", sprite = "item/assembling-machine-3", tooltip = "Open Pocket Crafter" }
    end
    pcraft.init_player(player)
end

function pcraft.open_gui(player)
    local gui = player.gui.left
    if gui.pcraft then
        gui.pcraft.destroy()
    else
        gui.add{type="frame", name="pcraft", label="Pocket Crafter"}
        gui.pcraft.add{type="flow", name="flow", direction="vertical"}
        local flow = gui.pcraft.flow
        flow.add{type="flow", direction="horizontal", name="row_1"}
        flow.row_1.add{type="label", caption="Recipe:"}
        flow.row_1.add{type="choose-elem-button", elem_type="item", name="pcraft_recipe"}
        flow.row_1.add{type="label", caption="Enabled:"}
        flow.row_1.add{type="checkbox", name="pcraft_enabled", state=true}
        flow.add{type="flow", direction="horizontal", name="row_2"}
        flow.row_2.add{type="label", caption="Status: "}
        flow.row_2.add{type="label", caption="", name="pcraft_status"}
        flow.add{type="progressbar", name="pcraft_progress"}
        flow.add{type="progressbar", name="pcraft_bonus_progress"}
        flow.pcraft_bonus_progress.style.color = {r=1, g=0, b=1}
        flow.add{type="button", caption="Upgrade", name="pcraft_upgrade"}
    end
end

function pcraft.gui_click(event)
    if not (event.element and event.element.valid) then return end
    local elem = event.element
	local player = game.players[event.element.player_index]
    local name = event.element.name
    if name == "pcraft" then
        pcraft.open_gui(player)
        return
    end
end

function pcraft.gui_elem_changed(event)
    if not (event.element and event.element.valid) then return end
    local elem = event.element
	local player = game.players[event.element.player_index]
    local name = event.element.name
    if name == "pcraft_recipe" then
        if player.force.recipes[elem.elem_value] and player.force.recipes[elem.elem_value].enabled then
            global.pcraft[player.index].recipe = elem.elem_value
            global.pcraft[player.index].energy = 0
            global.pcraft[player.index].bonus_energy = 0
            if pcraft.deduct_materials(player, player.force.recipes[elem.elem_value].prototype) then
                global.pcraft[player.index].enabled = true
            end
        else
            global.pcraft[player.index].recipe = nil
            global.pcraft[player.index].enabled = false
            player.print("Recipe not available.")
        end
        return
    end
end

function pcraft.deduct_materials(player, recipe_proto)
    --Does the player have the items?
    local multiplier = global.pcraft[player.index].multiplier
    for each, item in pairs(recipe_proto.ingredients) do
        if item.type == "fluid" then return false end
        if player.get_item_count(item.name) < item.amount * multiplier then
            player.print("Pocket Crafter: Insufficient " .. item.name .. ".")
            return false
        end
    end
    for each, item in pairs(recipe_proto.ingredients) do
        player.remove_item{name=item.name, count=item.amount * multiplier}
    end
    return true
end

function pcraft.give_products(player, recipe_proto)
    local multiplier = global.pcraft[player.index].multiplier
    for each, product in pairs(recipe_proto.products) do
        if product.type == "item" then
            player.insert{name=product.name, count=product.amount * multiplier}
            if not recipe_proto.hidden_from_flow_stats then
                player.force.item_production_statistics.on_flow(product.name, product.amount * multiplier)
            end
        end
    end
end

function pcraft.update()
    for k,player in pairs(game.connected_players) do
        local data = global.pcraft[player.index]
        if data and data.enabled then
            local recipe = player.force.recipes[data.recipe].prototype

            data.energy = data.energy + data.speed / 10
            data.bonus_energy = data.bonus_energy + data.bonus_speed / 10
            if data.energy > recipe.energy then
                data.energy = data.energy - recipe.energy
                pcraft.give_products(player, recipe)
                if not pcraft.deduct_materials(player, recipe) then
                    data.enabled = false
                end
            end
            if data.bonus_energy > recipe.energy then
                data.bonus_energy = data.bonus_energy - recipe.energy
                pcraft.give_products(player, recipe)
            end

            local gui = player.gui.left.pcraft
            if gui then 
                local status = gui.flow.row_2.status
                local progress = gui.flow.pcraft_progress
                local bonus_progress = gui.flow.pcraft_bonus_progress
                progress.value = data.energy / recipe.energy
                bonus_progress = data.bonus_energy / recipe.energy
            end
        end
    end
end

function pcraft.init_player(player)
    global.pcraft[player.index] = {}
    global.pcraft[player.index].speed = 1
    global.pcraft[player.index].bonus_speed = 0
    global.pcraft[player.index].multiplier = 1
    global.pcraft[player.index].enabled = false
end

--if rpg then
--	Event.register(rpg.on_rpg_gui_created, pcraft.add_gui)
--else
	Event.register(defines.events.on_player_created, pcraft.add_gui)
--end
Event.register(defines.events.on_gui_click, pcraft.gui_click)
Event.register(defines.events.on_gui_elem_changed, pcraft.gui_elem_changed)
script.on_nth_tick(6, pcraft.update)
