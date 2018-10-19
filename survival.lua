--Survival.  Biters attack YOU.
--Written by Mylon.
--Licensed under MIT license.
-- Scenario based on Hardcore Survival 0.9.7

-- FELLOW MODDERS -- To set difficulty remotely:
-- local diff = remote.call("survival", "getDifficulty")
-- remote.call("survival", "setDifficulty", diff * 0.6)

-- FELLOW MODDERS -- To add extra biters:
-- remote.call("survival", "addBiter", {name="bitername", cost=pointcost, evolution=minimumevolution})
-- Example:
-- remote.call("survival", "addBiter", {name="bob-big-piercing-biter", cost=9, minEvolution=0.7, maxEvolution=1})
-- Small biters should use a maxEvolution to keep pathfinder from bugging out.  Both minEvolution and MaxEvolution are optional.

if MODULE_LIST then
	module_list_add("Hardcore Survival")
end

VISION_RANGE=4 --Depreciated
MERCY_THRESHOLD=6
POLLUTION_AGGRO=4000 --Smaller is harder
EVOLUTION_SCALE = 4 --How fast does pollution bring bigger biters? Bigger is harder
LAB_ACCIDENT_BEAKERS=50 -- Average number of beakers between accidents.
global.busySpawn = 0

--For external mod use.
global.addCustomBiters = false
global.tempCustomBiters = {}
global.customBiters = {}

-- remote.add_interface("survival", {
-- 	table = function()
-- 		return global.spawnPoints 
-- 	end, 
-- 	pollution = function()
-- 		for n, p in pairs(game.connected_players) do
-- 			if p.admin then
-- 				p.print("Pollution: " .. getPollution())
-- 			end
-- 		end
-- 	end,
-- 	getDifficulty = function()
-- 		return global.modDifficulty
-- 	end,
-- 	setDifficulty = function(var)
-- 		global.modDifficulty = var
-- 	end,
-- 	getEventID = function()
-- 		return global.updateSurvivalTable
-- 	end,
-- 	addBiter = function(var)
-- 		log("Survival: Registering custom biter " .. var.name)
-- 		global.addCustomBiters = true
-- 		table.insert(global.tempCustomBiters, var)
-- 	end})

-- /silent-command remote.call("survival", "pollution")
-- /silent-command game.player.print(game.player.surface.count_entities_filtered{force="enemy"})
-- /silent-command game.player.print(game.forces.enemy.is_pathfinder_busy())
--For troublemakers.
-- /silent-command local trouble = "name" for x = -1, 1, 1 do for y = -1, 1, 1 do game.surfaces[1].create_entity{name="medium-biter", position={game.players[trouble].position.x+x, game.players[trouble].position.y+y}} end end

--Starting conditions.
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]  
  --Accelerated start.  A significant boost, but not a comfortable one.
	if ACCELERATED_START then
		player.insert{name="iron-plate", count=300}
		player.insert{name="copper-plate", count=200}
		player.insert{name="coal", count=200}
		player.insert{name="burner-mining-drill", count = 10}
		player.insert{name="steel-axe", count=10}
		player.insert{name="inserter", count=50}
		player.insert{name="stone-furnace", count=10}
		player.insert{name="assembling-machine-2", count=10}
		player.insert{name="transport-belt", count=200}
		player.insert{name="medium-electric-pole", count=50}
		player.insert{name="submachine-gun", count = 1}
		player.insert{name="piercing-rounds-magazine", count = 200}
		player.insert{name="gun-turret", count = 5}
		player.insert{name="modular-armor", count = 1}
			local p_armor = player.get_inventory(5)[1].grid
			p_armor.put({name = "solar-panel-equipment"})
			p_armor.put({name = "solar-panel-equipment"})
			p_armor.put({name = "solar-panel-equipment"})
			p_armor.put({name = "solar-panel-equipment"})
			p_armor.put({name = "solar-panel-equipment"})
			p_armor.put({name = "solar-panel-equipment"})
			p_armor.put({name = "battery-equipment"})
			p_armor.put({name = "battery-equipment"})
			p_armor.put({name = "battery-equipment"})
			p_armor.put({name = "battery-equipment"})
			p_armor.put({name = "personal-roboport-equipment"})
		player.insert{name="construction-robot", count = 10}
		player.insert{name="blueprint", count = 10}
		player.insert{name="blueprint-book", count = 1}
	-- Only needed for scenario version
	else
		-- Basic Start
		player.insert{name="iron-plate", count=8}
		player.insert{name="pistol", count=1}
		player.insert{name="firearm-magazine", count=10}
		player.insert{name="burner-mining-drill", count = 1}
		player.insert{name="stone-furnace", count = 1}
	end
	
	player.print("Welcome to Hardcore Survival: Super Offensive Biters.  There are no biter bases.  Biters come to attack you regularly.  They spawn just outside of radar range so keep your base well covered.")
  
  --player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
  -- if (#game.players <= 1) then
    -- game.show_message_dialog{text = {"msg-intro"}}
  -- else
    -- player.print({"msg-intro"})
  -- end
end)

--Win condition, unchanged from vanilla.
-- Necessary only for the scenario version.
script.on_event(defines.events.on_rocket_launched, function(event)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") == 0 then
    if (#game.players <= 1) then
      game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
    else
      for index, player in pairs(force.players) do
        player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
      end
    end
    return
  end
  if not global.satellite_sent then
    global.satellite_sent = {}
  end
  if global.satellite_sent[force.name] then
    global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
  else
    game.set_game_state{game_finished=true, player_won=true, can_continue=true}
    global.satellite_sent[force.name] = 1
  end
  for index, player in pairs(force.players) do
    if player.gui.left.rocket_score then
      player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
    else
      local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
      frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
      frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
    end
  end
end)

--Survive!
function spawnAttack()
	if game.forces.enemy.is_pathfinder_busy() then
		global.busySpawn = global.busySpawn + 1
		return
	end
	--if not global.spawnPoints then
		--game.print("Refreshing entire map.")
		--checkMap() --Changed to a vision-base check, so we need to update this often.
		--Obsolete in v0.15, can just check chunk visibility
	--end
	--game.print("Coming to get you!")
	local pollution = math.max(1, math.floor(getPollution() / POLLUTION_AGGRO))
	--Add in some extra due to game time.
	pollution = pollution + game.tick / (60 * 60 * 5)
	local online = #game.connected_players
	--Change scale based on number of connected players.
	pollution = pollution * online / (4 + online)
	--Change scale based on installed mods
	pollution = pollution * global.modDifficulty
	local evo = game.evolution_factor
	--log(serpent.line(global.spawnPoints))
	
	local spawn = getSpawn()
	local spawnX = spawn[1]
	local spawnY = spawn[2]
	-- if global.spawnPoints[spawnX] then
		-- spawnY = getRandomKey(global.spawnPoints[spawnX])

	-- else
		-- return --Error, empty table!
	-- end
		-- if not spawnY then
			-- global.spawnPoints[spawnX] = nil
			-- log("Survival: spawnPoints[" .. spawnX .."] is empty.")
			-- return --You're spared.  This time.
		-- end
	-- else
		-- return --Error!  empty table.
	-- end
	-- Last one is precision.  Shouldn't be too important since this should spawn stuff super far away.
	--local spawnPoint = game.surfaces[1].find_non_colliding_position("behemoth-biter", {spawnX*32, spawnY*32}, 40, 5)
	
	-- if not spawnPoint then --You got lucky.
		-- --global.spawnPoints[spawnX][spawnY] = nil
		-- log("Survival: No valid spawn location found.")
		-- return
	-- end
	local biters = {}
	--for i = MERCY_THRESHOLD, pollution, 1 do
		--game.print("Biter spawned.")
		local spawned = false
		local points = math.max(2, MERCY_THRESHOLD - game.tick / (60 * 60 * 5))
	while points < pollution do
		for k, v in pairs(global.customBiters) do
			local minE = 0
			local maxE = 1
			if v.minEvolution then
				minE = v.minEvolution
			end
			if v.maxEvolution then
				maxE = v.maxEvolution
			end
			if evo >= minE and evo < maxE then
				local biter = v.name
				points = points + v.cost
				table.insert(biters, biter)
			end
		end
		if evo > 0.9 then
			--Limit to 1/4 of points
			--while points < pollution / 4 do
				--Spawn behemoth biter
				local biter = "behemoth-biter"
				table.insert(biters, biter)
				points = points + 23
				spawned = true
			--end
		end
		if evo > 0.9 then
			-- while points < pollution / 3 do
				--Spawn behemoth spitter
				local biter = "behemoth-spitter"
				table.insert(biters, biter)
				points = points + 23
				spawned = true
			-- end
		end
		if evo > 0.8 then
			-- while points < pollution * 0.4 do
				--Spawn big spitter
				local biter = "big-spitter"
				table.insert(biters, biter)
				points = points + 14
				spawned = true
			-- end
		end
		if evo > 0.7 then
			-- while points < pollution * 0.6 do
				--Spawn big biter
				local biter = "big-biter"
				table.insert(biters, biter)
				points = points + 12
				spawned = true
			-- end
		end
		if evo > 0.5 then
			if global.busySpawn < 4 or evo <= 0.7 then
				--Spawn medium-spitter
				local biter = "medium-spitter"
				table.insert(biters, biter)		
				points = points + 10
				spawned = true
			end
		end
		if evo > 0.3 then
			if global.busySpawn < 3 or evo <= 0.5 then
				--Spawn medium biter
				local biter = "medium-biter"
				table.insert(biters, biter)
				points = points + 7 --More expensive because fun stuff.
				spawned = true
			end
		end
		if evo > 0.2 then
			if global.busySpawn < 2 or evo <= 0.3 then
				--Spawn small spitter
				local biter = "small-spitter"
				table.insert(biters, biter)
				points = points + 3
				spawned = true
			end
		end
		if global.busySpawn < 1 or evo <= 0.2 then
			local biter = "small-biter"
			table.insert(biters, biter)
			points = points + 1
			--game.print("Biter spawned.")
		end
	end
	
	local spawnPoint = game.surfaces[1].find_non_colliding_position("behemoth-biter", {spawnX*32, spawnY*32}, 20, 2)
	local group
	if spawnPoint then
			group = game.surfaces[1].create_unit_group{position = spawnPoint}
	else
		log("Survival: No valid spawn location for group.")
		return
	end
	
	--Normally they don't spawn on top of each other if I use the same x,y, but occasionally they do.
	for i, spawn in pairs(biters) do
		local spawnPoint = game.surfaces[1].find_non_colliding_position("behemoth-biter", {spawnX*32, spawnY*32}, 20, 2)
		if spawnPoint then
			local bitebite = game.surfaces[1].create_entity{name=spawn, position=spawnPoint}
			group.add_member(bitebite)
		end
	end
		
	--end
	-- Now send them to attack.
	
	-- for i, biter in pairs(biters) do
		-- group.add_member(biter)
	-- end
	
--Pick a random player to pick on.
	local target
	if math.random() > 0.9 then
		local p = game.connected_players
		local pc = {}
		for t,g in pairs(p) do
			if g.surface ~= game.surfaces[1] then
				table.insert(pc, g)
			end
		end
		if #pc > 0 then
			target = pc[math.random(1,#pc)].character
		end
	end
	
	if not target then

		target = game.surfaces[1].find_nearest_enemy{
			position=group.position,	
			force=game.forces.enemy,
			max_distance=4000
		}
	end
	
	
	--group.set_autonomous()
	
	-- if target then
		-- group.set_command{type=defines.command.compound, structure_type=defines.compound_command.return_last, commands={
			-- {type=defines.command.attack, target=game.surfaces[1].find_nearest_enemy{position=group.position, max_distance=1000, force="enemy"}},
			-- {type=defines.command.attack_area, destination=target.position, radius=1000},
			-- {type=defines.command.attack_area, destination={0,0}, radius=3000}}
		-- }
	-- else
		-- group.set_command{type=defines.command.attack_area, destination={0,0}, radius=1000}
	-- end
	
	
	if target then
		group.set_command{type=defines.command.attack, target=target}
	else
		group.set_command{type=defines.command.attack_area, destination={0,0}, radius=1000}
	end
	if global.busySpawn > 0 then
		global.busySpawn = global.busySpawn - 1
	end
end

--Until I figure out how to control them properly...
function massAttack(event)
	if not (event.tick % (60 * 60 * 15) == 0) then
		return
	end
	
	for i, biter in pairs(game.surfaces[1].find_entities_filtered{force="enemy", type="unit"}) do
		biter.set_command{type=defines.command.attack_area, destination={0,0}, radius=600}
	end
end

--Unique behavior
function splitters(event)
	if not global.zombies then
		global.zombies = {}
	end
	--Biters have a 1/20 chance of turning into a same-size worm.
	--Worms have a 1/20 chance of spawning 5 lower level biters
	--Worms have a 1/100 chance of spawning 10 lower level biters (stacks)
	if event.entity.name == "big-biter" and math.random(1,10) == 10 then
		event.entity.surface.create_entity{name="big-worm-turret", position=event.entity.position}
	end
	if event.entity.name == "big-worm-turret" and math.random(1,2) == 2 then
		for i=0, 5, 1 do
			event.entity.surface.create_entity{name="small-biter", position=event.entity.position}
		end
	end
	if event.entity.name == "acid-projectile-purple" then
		local pos = getRandom(global.spawnPoints)
		event.entity.surface.create_entity{name="small-biter", position=event.entity.position}
	end
	if event.entity.name == "medium-biter" and math.random(1,2) == 2 then
		table.insert(global.zombies, {tick=game.tick, position=event.entity.position})
	end
end

function checkZombies()
	if not global.zombies then
		global.zombies = {}
	end
	for i, zombie in pairs(global.zombies) do
		if game.tick > zombie.tick + (60*60*2) then
			local spawnPoint = game.surfaces[1].find_non_colliding_position("medium-biter", zombie.position, 10, 3)
			if spawnPoint then
				game.surfaces[1].create_entity{name="medium-biter", position=zombie.position}
			end
			table.remove(global.zombies, i)
		end
	end
end

function labAccident()
	if not ((game.tick+5800) % (60 * 60 * 5) == 0) then
	--if not ((game.tick+5800) % (60) == 0) then --Debug
		return --Not our time.
	end
	if not global.labs then
		return --No labs to check.
	end
	if #global.labs == 0 then --Biters won?
		return
	end
	
	local index = math.random(1,#global.labs)
	local lab = global.labs[index]
	if not (lab and lab.valid) then
		table.remove(global.labs, index)
		return --Was destroyed.  Got lucky this time.
	end
	
	local alienEgg = false
	if not lab.force.current_research then
		return
	end
	local ingred = lab.force.current_research.research_unit_ingredients
	for i, ing in pairs(ingred) do
		if ing.name == "alien-science-pack" then
			alienEgg = true
		end
	end

	if alienEgg then
		local spawnPoint = game.surfaces[1].find_non_colliding_position("big-biter", lab.position, 10, 3)
		if spawnPoint then
			game.surfaces[1].create_entity{name="big-biter", position=lab.position}
		end
	end
	
end

-- function checkMap()
-- 	local players = game.players
-- 	-- local radars = game.surfaces[1].find_entities_filtered{type="radar"}
-- 	-- global.visible = {}
-- 	global.spawnPoints = {}
-- 	for _, p in pairs(players) do
-- 		visionRadius(p)
-- 	end
-- 	for _, p in pairs(radars) do
-- 		if p.electric_drain then--Check if powered
-- 			visionRadius(p)
-- 		end
-- 	end
	
-- 	for sx, sxlist in pairs(global.visible) do
-- 		for sy, sbool in pairs(sxlist) do
-- 			--Check north
-- 			if not sxlist[sy-1] then--Valid spawn
-- 				spawnAdd(sx, sy-1)
-- 			end
-- 			--Check east
-- 			if not (global.visible[sx+1] and global.visible[sx+1][sy]) then
-- 				spawnAdd(sx+1, sy)
-- 			end
-- 			--Check south
-- 			if not sxlist[sy+1] then
-- 				spawnAdd(sx, sy+1)
-- 			end
-- 			--Check west
-- 			if not (global.visible[sx+1] and global.visible[sx+1][sy]) then
-- 				spawnAdd(sx+1, sy)
-- 			end
-- 		end
-- 	end
-- 	--These don't actually work.  #sparseTable returns weird values.
-- 	-- game.print("Map checked. " .. #global.spawnPoints .. " chunks along x axis found.")
-- 	-- game.print("Map checked. " .. #global.spawnPoints[0] .. " chunks along y axis (x=0) found.")
-- end

-- function visionRadius(ent)
-- 	local entx = math.floor(ent.position.x/32)
-- 	local enty = math.floor(ent.position.y/32)
-- 	for x = -VISION_RANGE, VISION_RANGE, 1 do
-- 		for y = -VISION_RANGE, VISION_RANGE, 1 do
-- 			if not global.visible[entx + x] then
-- 				global.visible[entx + x] = {}
-- 			end
-- 			global.visible[entx + x][enty + y] = true
-- 		end
-- 	end
-- end

function spawnAdd(sx, sy)
	if not global.spawnPoints[sx] then
		global.spawnPoints[sx] = {}
	end
	global.spawnPoints[sx][sy] = true
end

function checkForAttack(event)
	--if (event.tick+1) % (math.max(60, math.floor((1 - game.evolution_factor) * 60 * 60))) == 0 then
	-- Spawn 1 wave every minute for 10 minutes, then a five minute break.
	if (event.tick / (60 * 60)) % (15) <= 10 then
		if (event.tick+120) % (60 * 60) == 0 then
			spawnAttack()
		end
	end
end

function getSpawn()
	local candidates = {}
	-- for x, sx in pairs(global.spawnPoints) do
	-- 	for y, sy in pairs(global.spawnPoints[x]) do
	-- 		table.insert(candidates, {x, y})
	-- 	end
	-- end
	for chunk in game.surfaces[1].get_chunks() do
		if game.forces.player.is_chunk_visibile(1, chunk) then
			if game.forces.player.is_chunk_visibile(1, {chunk.x+1, chunk.y}) or
			game.forces.player.is_chunk_visibile(1, {chunk.x, chunk.y+1}) or
			game.forces.player.is_chunk_visibile(1, {chunk.x-1, chunk.y}) or
			game.forces.player.is_chunk_visibile(1, {chunk.x, chunk.y}) then

				table.insert(candidates, chunk)
		end
	end
	if #candidates > 0 then
		return candidates[math.random(1,#candidates)]
	end
end

function addLab(event)
	if not global.labs then
		global.labs = {}
	end
	if event.created_entity.name == "lab" then
		table.insert(global.labs, event.created_entity)
	end
end

-- No biter bases allowed.
function killBases(event)
	local bases = event.surface.find_entities_filtered{force="enemy", area=event.area}
	for i, base in pairs(bases) do
		base.destroy()
	end
end

-- Utility functions
function getRandomKey(tabl)
	--Obsolete in 0.15.24
	-- local count = 0
	-- for k, v in pairs(tabl) do
	-- 	count = count + 1
	-- end
	-- if count == 0 then
	-- 	log("Survival: Table is empty.")
	-- 	return
	-- end
	local count = table_size(tabl)
	local pick = math.random(1,count)
	count = 0
	for k, v in pairs(tabl) do 
		count = count + 1
		if count == pick then
			return k
		end
	end
end

function getPollution()
	local pollution = 0
	for chunk in game.surfaces[1].get_chunks() do
		pollution = pollution + game.surfaces[1].get_pollution({chunk.x*32, chunk.y*32})
	end
	return pollution
end

function nerfBat(force)
	force.set_turret_attack_modifier("flamethrower-turret", -0.5)
	force.set_turret_attack_modifier("laser-turret", -0.2)
end

function nerfSolar()
	if game.surfaces[1].daytime > 0.8 then
		game.surfaces[1].daytime = 0.2
	end
end

function addCustomBiters()
	--First remove potential duplicate entries.
	for i = #global.tempCustomBiters, 1, -1 do
		for __, valueold in pairs(global.customBiters) do
			if global.tempCustomBiters[i].name == valueold.name then
				table.remove(global.tempCustomBiters, i)
			end
		end
	end
	for k, v in pairs(global.tempCustomBiters) do
		table.insert(global.customBiters, v)
	end
	global.tempCustomBiters = {}
	global.addCustomBiters = false
end

--Event triggers
event.register(defines.events.on_chunk_generated, killBases)
-- script.on_event(defines.events.on_chunk_generated, function(event)
-- 	killBases(event)
-- 	-- Scenario Addon: Global Warming
-- 	checkChunk(event)
-- end)

Event.register(defines.events.on_built_entity, addLab)

-- script.on_event(defines.events.on_built_entity, function(event)
-- 	addLab(event)
-- end)

Event.register(defines.events.on_robot_built_entity, addLab)

-- script.on_event(defines.events.on_robot_built_entity, function(event)
-- 	addLab(event)
-- end)

Event.register(defines.events.on_entity_died, splitters)

-- script.on_event(defines.events.on_entity_died, function(event)
-- 	--spawnArtifact(event)
-- 	splitters(event)
-- end)

Event.register(defines.events.on_tick, checkForAttack)
Event.register(defines.events.on_tick, massAttack)
Event.register(defines.events.on_tick, checkZombies)
Event.register(defines.events.on_tick, labAccident)
Event.register(defines.events.on_tick, nerfSolar)


-- script.on_event(defines.events.on_tick, function(event)
-- 	checkForAttack(event)
-- 	massAttack(event) --Technically this is the garbage collection.
-- 	checkZombies(event)
-- 	labAccident()
-- 	if global.addCustomBiters then
-- 		addCustomBiters()
-- 	end
-- 	nerfSolar(event)
-- 	-- Scenario addon: Dirt Path
-- 	if event.tick % 30 == 0 then
-- 		dirtDirt()
-- 	end
-- 	if (event.tick+50) % (60 * 60 * 5) == 0 then
-- 		cleanDirt()
-- 	end
-- 	-- Scenario addon: Global Warming
-- 	waterWorld(event)
-- 	desertification(event)
-- 	if event.tick % 3823 == 0 then
-- 		recheckMap()
-- 	end
-- end)

-- script.on_configuration_changed(function()
-- 	global.busySpawn = 0 --Technically a migration from 0.9.2
-- 	global.customBiters = {} -- In case any mods are removed.
	
-- 	--To migrate from 0.9.4
-- 	global.addCustomBiters = false
-- 	global.tempCustomBiters = {}
-- 	if not global.modDifficulty then
-- 		global.modDifficulty = 1

-- 		log("Survival: Migrating from 0.9.4")

-- 		if game.active_mods["bobplates"] then
-- 			global.modDifficulty = global.modDifficulty * 0.4
-- 		end
-- 		if game.active_mods["angelsrefining"] then
-- 			global.modDifficulty = global.modDifficulty * 0.7
-- 		end
-- 		if game.active_mods["angelspetrochem"] then
-- 			global.modDifficulty = global.modDifficulty * 0.7
-- 		end
-- 		if game.active_mods["Prospector"] then
-- 			global.modDifficulty = global.modDifficulty * 0.7
-- 		end
-- 		if game.active_mods["bobwarfare"] then
-- 			global.modDifficulty = global.modDifficulty * 1.3
-- 		end
-- 	end
	
-- 	game.map_settings.enemy_evolution.pollution_factor = 0.000015 * EVOLUTION_SCALE * global.modDifficulty
-- end)

Event.register(-1, survival_init)

function survival_init()
	global.customBiters = {}
	global.modDifficulty = 1
	nerfBat(game.forces.player)
	
	if game.active_mods["bobplates"] then
		global.modDifficulty = global.modDifficulty * 0.4
	end
	if game.active_mods["angelsrefining"] then
		global.modDifficulty = global.modDifficulty * 0.7
	end
	if game.active_mods["angelspetrochem"] then
		global.modDifficulty = global.modDifficulty * 0.7
	end
	if game.active_mods["Prospector"] then
		global.modDifficulty = global.modDifficulty * 0.7
	end
	if game.active_mods["bobwarfare"] then
		global.modDifficulty = global.modDifficulty * 1.3
	end
	
	game.map_settings.enemy_evolution.pollution_factor = 0.000015 * EVOLUTION_SCALE * global.modDifficulty
	--In case anyone is adding this mod late
	for i, enemy in pairs(game.surfaces[1].find_entities_filtered{force="enemy"}) do
		enemy.destroy()
	end
end