--Mass to Power converter.  Better than a mass energy converter!
--Written by Mylon, 2018-10
--MIT License

if MODULE_LIST then
	module_list_add("Mass to Power")
end

mass_power = {}
global.mass_power = {power = 0, targets = {}, target_index}

--Create the converter and input chest
function mass_power.init()
    local eei = game.surfaces[1].create_entity{name="electric-energy-interface", position={-5, 0}, force=game.forces.player}
    eei.operable = false
    eei.minable = false
    eei.destructible = false
    global.mass_power.eei = eei
end

--Consume goods in the sacrifice chest and set power.
function mass_power.feed()
    global.mass_power.eei.electric_output_flow_limit = global.mass_power
end

--Converter is angry!  Attacks other generators.
function mass_power.acquire(event)
    if not(event.created_entity.type == "assembling-machine") then
        return
    end
    table.insert(global.mass_power, event.created_entity)
end

function mass_power.checker(event)
    -- Iterate ovre up to 30 entities
    for i = 0, 29 do
        if i >= #global.mass_power.targets then
            return
        end
        if global.mass_power.target_index + i > #global.mass_power.targets then
            global.mass_power.target_index = 1
        end
        local entity = global.mass_power.targets[global.mass_power.target_index + i]
        if entity.valid then
            mass_power.angry(entity)
        else
            table.remove(global.mass_power.targets, global.mass_power.target_index + i)
        end
        global.mass_power.target_index = global.mass_power.target_index + 1
    end
end

function mass_power.angry()

end

script.on_nth_tick(301, mass_power.angry())