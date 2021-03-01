--Rainbow names!
--Written by Mylon, Feb 2018
--MIT License

global.nyan = {}
nyan = {}

commands.add_command("nyan", "Become nyan cat", function(params)
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
    if not global.nyan[target.name] then
        global.nyan[target.name] = {index=1, old_pos = game.player.position }
    else
        global.nyan[target.name] = nil
    end
end)

function nyan.nyan(event)
    local player = game.players[event.player_index]
    if global.nyan[player.name] then
        nyan.nyannyan()
        local particle = nyan.nyannyannyan[global.nyan[player.name].index]
        local movement = {(player.position.x - global.nyan[player.name].old_pos.x) / 10 + math.random() / 20 - 0.025, (player.position.y - global.nyan[player.name].old_pos.y) / 10 + math.random() / 20 - 0.025}
        global.nyan[player.name].old_pos = player.position
        
        player.surface.create_entity{name=particle, position=player.position, movement=movement, direction=0, frame_speed=0.01, vertical_speed=-0.001, height=1}
        
        global.nyan[player.name].index = global.nyan[player.name].index + 1
        if global.nyan[player.name].index > #nyan.nyannyannyan then
            global.nyan[player.name].index = 1
        end
    end
end

function nyan.nyannyan()
    if nyan.nyannyannyan then return end
    nyan.nyannyannyan = {}
    for k,v in pairs(game.entity_prototypes) do
        if v.type == "particle" then
            table.insert(nyan.nyannyannyan, v.name)
        end
    end
end

Event.register(defines.events.on_player_changed_position, nyan.nyan)
