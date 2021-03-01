-- Create a list of modules for display on login.
-- Each file should include a block like this:
-- if MODULE_LIST then
--     module_list_add("this module name")
-- end

MODULE_LIST = true
global.module_list = {}

function module_list_add(str)
    str = tostring(str) --Just in case.
    if #global.module_list > 0 then
        str = ", " .. str 
    end
    table.insert(global.module_list, str)
end

function module_list_print(player)
    local display = "Modules active: "
    for i=1, #global.module_list do
        display = display .. global.module_list[i]
    end
    player.print(display)
end

function module_list_connect(event)
    module_list_print(game.players[event.player_index])
end

-- The event that causes the module list to display
Event.register(defines.events.on_player_joined_game, module_list_connect)