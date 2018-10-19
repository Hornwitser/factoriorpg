--Builders get special turrets as a function of their level.  These turrets can level up.

rpg.builder = {}

--Calculate how many upgraded turrets a player is allowed.
function rpg.builder.turrets(player)
    if global.rpg_tmp[player.name].class = "Builder" then
        return math.floor(global.rpg_tmp[player.name].level / 4)
    end
end

--This is called by the calculate team bonus function.
function rpg.builder.reset_bonuses(force)
    local turrets = game.forces["level-2"]
    local ammotypes = {}
	local turrettypes = {}
	for k,v in pairs(force.technologies) do
		--if v.researched then
			for n, p in pairs(v.effects) do
				if p.type=="ammo-damage" then
					ammotypes[p.ammo_category]=true
				end
				if p.type=="turret-attack" then
					turrettypes[p.turret_id]=true
				end
			end
		--end
	end
    -- Malus for ammo is base * 0.8 - 0.2
	for k, v in pairs(ammotypes) do
		if string.find(k, "turret") then
			force.set_ammo_damage_modifier(k, force.get_ammo_damage_modifier(k) + 0.5)
        end
    end
end

function rpg.builder.init()
    local turret = game.create_force("level-2")
	turret.set_friend(game.forces.player, true)
end

Event.register(-1, rpg.builder.init)