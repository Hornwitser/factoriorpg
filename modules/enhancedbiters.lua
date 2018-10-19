-- Enhanced Biters, a mod for more dangerous biters
-- Factorio module by Mylon, 2018
-- MIT License

if MODULE_LIST then
	module_list_add("Enhanced Biters")
end

global.zombies = {}
global.capsules = {}

ENHANCED_SCALE = 1 --1 means 50% turret damage after 24h.  2 means 12h.

--Unique behaviors
function splitters(event)
	if event.entity.force.name ~= "enemy" then
		return
	end
	if not global.zombies then
		global.zombies = {}
	end
	
	if string.find(event.entity.name, "behemoth") and string.find(event.entity.name, "spitter") and math.random() < 0.08 then
		event.entity.surface.create_entity{name="big-worm-turret", position=event.entity.position}
	end
	if string.find(event.entity.name, "big") and string.find(event.entity.name, "worm") and math.random() < 0.25 then
		for i=0, 5, 1 do
			local pos = event.entity.surface.find_non_colliding_position("medium-biter", event.entity.position, 10, 3)
			event.entity.surface.create_entity{name="medium-worm-turret", position=pos}
		end
	end
	if string.find(event.entity.name, "medium") and string.find(event.entity.name, "worm") and math.random() < 0.5 then
		for i=0, 5, 1 do
			local pos = event.entity.surface.find_non_colliding_position("medium-biter", event.entity.position, 10, 2)
			event.entity.surface.create_entity{name="small-worm-turret", position=pos}
		end
	end
	if string.find(event.entity.name, "medium") and string.find(event.entity.name, "biter") and math.random() < 0.6 then
		--Is it on fire?
		local stickers = event.entity.stickers or {}
		local isonfire = false
		for k,v in pairs(stickers) do
			if v.name == "fire-sticker" then
				isonfire = true
				break
			end
		end
		if not isonfire then
			table.insert(global.zombies, {tick=game.tick, position=event.entity.position, surface=event.entity.surface, name=event.entity.name})
		end
	end
	if string.find(event.entity.name, "big") and string.find(event.entity.name, "spitter") and math.random() < 0.2 then
		if event.cause and event.cause.valid then
			local capsule = event.entity.surface.create_entity{name="acid-projectile-purple", position=event.entity.position, speed=0.5, target=event.cause}
			table.insert(global.capsules, {entity = capsule, target=event.cause, type="medium-biter", count=2})
		end
	end
end

function delayed_spawn()
	if not global.zombies then
		global.zombies = {}
	end
	for i = #global.zombies, 1, -1 do
		local zombie = global.zombies[i]
		if game.tick > zombie.tick + (60*60*2) then
			local spawnPoint = zombie.surface.find_non_colliding_position("medium-biter", zombie.position, 10, 3)
			local area = {{zombie.position.x - 2, zombie.position.y -2}, {zombie.position.x + 2, zombie.position.y + 2}}
			if spawnPoint then
				zombie.surface.create_entity{name=zombie.name, position=zombie.position}
				local corpse = zombie.surface.find_entities_filtered{name=zombie.name .. "-corpse", area=area, limit=1}[1]
				if corpse then
					corpse.destroy()
				end
			end
			table.remove(global.zombies, i)
		end
	end
	for i = #global.capsules, 1, -1 do
		local capsule = global.capsules[i]
		if not (capsule.entity and capsule.entity.valid) then --Projectile found its mark.
			--game.print("Popping Capsule")
			for n = 1, capsule.count do
				if capsule.target and capsule.target.valid then
					local spawnPoint = capsule.target.surface.find_non_colliding_position("small-biter", capsule.target.position, 10, 2)
					if spawnPoint then
						capsule.target.surface.create_entity{name=capsule.type, position=spawnPoint}
					end
				end
			end
			table.remove(global.capsules, i)
		end
	end
end

function tech_nerf(event)
	local force = event.force
	local scale = 5184000 / ENHANCED_SCALE
	local factor = scale / (scale + game.tick) --Decrease by 50% per 12h.
	local turret_types = {"gun-turret", "laser-turret", "flamethrower-turret", "flamethrower-turret", "artillery-turret"} --Flamethrower turret is in here twice intentionally.  🔥 OP
	for k,v in pairs(turret_types) do
		force.set_turret_attack_modifier(v, (force.get_turret_attack_modifier(v) + 1) * factor - 1)
	end
	--For extra fun, let's buff biters.
	game.forces.enemy.set_ammo_damage_modifier("melee", 0.5 + (2 * scale + game.tick) / (2 * scale) )
	game.forces.enemy.set_ammo_damage_modifier("biological", (scale + game.tick) / (scale) )
end

--Currently we rely upon the RPG module to call this often.
if rpg then
	Event.register(rpg.on_reset_technology_effects, tech_nerf)
end
Event.register(defines.events.on_entity_died, splitters)
Event.register(defines.events.on_tick, delayed_spawn)