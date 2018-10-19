--Rainbow names!
--Written by Mylon, Feb 2018
--MIT License

global.rainbow = {}

commands.add_command("rainbow", "Rainbow chat colors!", function(params)
    if not (game.player and game.player.admin) then return end
    local target
    if params and params.parameter then
        target = game.players[params.parameter:lower()]
        if not target then
            game.player.print("Invalid player name.")
            return
        end
    else
        target = game.player
    end
    if not global.rainbow[target.name] then
        global.rainbow[target.name] = 1800000 * math.random() --This is an offset so everyone doesn't have the same color.
    else
        global.rainbow[target.name] = nil
        target.color = {}
        target.chat_color = {}
    end
end)

function rainbow()
    for k,v in pairs(global.rainbow) do
        if game.players[k] and game.players[k].connected then
            local player = game.players[k]
            local color = {
                r = math.sin((game.tick + global.rainbow[player.name]) / 1700) * 127 + 127,
                b = math.sin((game.tick + 600 + global.rainbow[player.name]) / 1800) * 127 + 127,
                g = math.sin((game.tick + 1200 + global.rainbow[player.name]) / 1900) * 127 + 127
            }
            player.color = color
            for k,v in pairs(color) do
                color[k] = 63 + v*3/4
            end
            player.chat_color = color
        end
    end
end

script.on_nth_tick(3, rainbow)