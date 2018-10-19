function rpg_beast_taming(event)
	--game.print("Entity died.")
	if event.entity.type == "unit-spawner" then
		local player = nil
		if event.cause and event.cause.type == "player" then
			player = event.cause.player
		elseif event.cause and event.cause.last_user then
			player = event.cause.last_user
		end
		
		if player then
			if global.rpg_exp[player.name].class == "Beastmaster" then
				--Conditions met.  Check for friendly biter spawn.
				-- 4% chance per level of gaining a medium biter pet.
				if math.random() < global.rpg_tmp[player.name].level * 4 / 100 then
					rpg_add_pet(player)
				end
			end
		end
	end
end

function rpg_beast_sickem(event)
	--Check 4 times per second
	if event.tick % 15 == 0 then
		for n, p in pairs(game.players) do
			if p.connected then
				if global.rpg_exp[p.name] and global.rpg_exp[p.name].class == "Beastmaster" then
					if global.rpg_tmp[p.name].pets and global.rpg_tmp[p.name].pets.valid then
						if p.shooting_state.state ~= defines.shooting.not_shooting then
							local enemy = p.surface.find_nearest_enemy{position=p.position, max_distance=64}
							if enemy then 
								global.rpg_tmp[p.name].pets.set_command{type=defines.command.attack, target=enemy}
							else
								global.rpg_tmp[p.name].pets.set_command{type=defines.command.go_to_location, destination=p.position}
							end
						--elseif not global.rpg_tmp[p.name].pets.state == defines.group_state.moving then
						elseif global.rpg_tmp[p.name].pets.state == defines.group_state.finished then
							--TODO: Set the destination to position + direction so biters keep up better.
							global.rpg_tmp[p.name].pets.set_command{type=defines.command.go_to_location, destination=p.position}
						end
					else
					--Group expired?  Let's try rounding them up.
						local level = global.rpg_tmp[p.name].level
						local packsize = math.ceil(level/4)
						local beasts = p.surface.find_entities_filtered{position=p.position, count=packsize, force="beasts"}
						if #beasts > 0 then
							global.rpg_tmp[p.name].pets = p.surface.create_unit_group{position=p.position, force=game.forces.beasts}
						end
						for k, v in pairs(beasts) do
							global.rpg_tmp[p.name].pets.add_member(v)
						end
					end
				end
			end
		end
	end
end

function rpg_free_pets(event)
	if event.tick % (60 * 60) == 0 then
		for n, p in pairs(game.players) do
			if p.connected then
				if global.rpg_exp[p.name] and global.rpg_exp[p.name].class == "Beastmaster" then
					--Check to see if the player is in the wild.  If there are nearby belts or assemblers, skip.
					local pos = p.position
					local area = {{pos.x-100, pos.y-100}, {pos.x+100, pos.y+100}}
					local beltcount = p.surface.count_entities_filtered{area=area, type="transport-belt"}
					local assemblercount = p.surface.count_entities_filtered{area=area, type="assembling-machine"}
					if beltcount == 0 and assemblercount == 0 then
						rpg_add_pet(p)
					end
				end
			end
		end
	end
end
						

function rpg_add_pet(player)
	--Can the player have more pets?
	if global.rpg_tmp[player.name].pets and global.rpg_tmp[player.name].pets.valid and #global.rpg_tmp[player.name].pets.members > global.rpg_tmp[player.name].level / 4 then
		return
	end
	local biter_type = "big-biter" --Default biter type.
	if game.forces.enemy.evolution_factor > 0.9 and math.random() < 0.05 then
		biter_type = "behemoth-biter"
	elseif game.forces.enemy.evolution_factor > 0.7 and math.random() < 0.10 then
		biter_type = "big-spitter"
	elseif game.forces.enemy.evolution_factor > 0.6 and math.random() < 0.10 then
		biter_type = "medium-spitter"
	end
	local pos = player.surface.find_non_colliding_position("behemoth-biter", player.position, 10, 2)
	if pos then
		local pet = player.surface.create_entity{name=biter_type, position=pos, force=game.forces.beasts}
		pet.last_user = player --So the player gets credit for its kills!
		if not (global.rpg_tmp[player.name].pets and global.rpg_tmp[player.name].pets.valid) then
			global.rpg_tmp[player.name].pets = player.surface.create_unit_group{position=pos, force=game.forces.beasts}
		end
		global.rpg_tmp[player.name].pets.add_member(pet)
	end
end
						
function rpg_beast_init()
	local beasts = game.create_force("beasts")
	beasts.set_friend(game.forces.player, true)
	beasts.set_friend(game.forces.enemy, false)
	game.forces.player.set_friend(beasts, true)
	beasts.ai_controllable = false --This is what's causing them to nom belts?
	beasts.friendly_fire = false
end

Event.register(defines.events.on_entity_died, rpg_beast_taming)
Event.register(defines.events.on_tick, rpg_beast_sickem)
Event.register(defines.events.on_tick, rpg_free_pets)
Event.register(-1, rpg_beast_init)