--Bluebuild softmod, based on version 1.1.4
AUTO_OFF_TIMER = 60 * 60 * 15 --15 minutes

if MODULE_LIST then
	module_list_add("Bluebuild")
end

bluebuild = {}

-- Find ghosts to place.  Then find buildings to destruct.
function bluebuild.runOnce()
	global.runOnce = true
	global.blueBuildSwitch = true
	global.ghosts = {}
	global.blueBuildFirstTick = {}
	global.bluePosition = {}
	global.blueBuildToggle = {}
	global.blueDemoToggle = {}
	global.blueLastDemo = {}
	global.blueBuildLastBuild = {}
	global.blueBuildOptin = {}
end

function bluebuild.initPlayer(event)
	if not global.runOnce then
		runOnce()
	end
	global.blueBuildToggle[event.player_index] = false
	global.blueDemoToggle[event.player_index] = false
	global.blueBuildFirstTick[event.player_index] = game.tick
	global.blueBuildLastBuild[event.player_index] = game.tick
	global.blueLastDemo[event.player_index] = game.tick
	global.blueBuildOptin[event.player_index] = true
end

function bluebuild.playerloop()
	if not global.runOnce then
		runOnce()
	end
	if not global.blueBuildSwitch then
		return
	end
	
	-- for iPlayer = 1, #game.players do
		-- if game.players[iPlayer] and game.players[iPlayer].connected then
			-- bluecheck(game.players[iPlayer])
		-- end
	-- end
	
	for _, player in pairs(game.players) do
		if player.connected then
			--Each player only gets checked once per (6 * online players) ticks.
			if bluebuild.turn(player) then
				--Toggle build/demo flags if player is idle.
				--Set to 2 minutes
				if global.blueBuildLastBuild[player.index] < game.tick - AUTO_OFF_TIMER then
					global.blueBuildToggle[player.index] = false
				end
				if global.blueBuildLastBuild[player.index] < game.tick - AUTO_OFF_TIMER then
					global.blueDemoToggle[player.index] = false
				end
				--Now check for stuff to build/tear down.
				bluebuild.check(player)
			end
		end
	end
end

--Necessary because Lua loops suck.
function bluebuild.turn(player)
	if ((game.tick + 6 * player.index) % (6 * math.max(1, #game.connected_players)) == 0) then
		return true
	else
		return false
	end
end

function bluebuild.check(builder)
	local pos = builder.position
	--game.print("Checking player.")
	-- if global.bluePosition[builder.index] and global.bluePosition[builder.index] == pos then
	if global.bluePosition[builder.index] and global.bluePosition[builder.index].x == pos.x and global.bluePosition[builder.index].y == pos.y then
		--We haven't moved.  Good, let's continue.
		--game.print("Player hasn't moved.")
		if global.blueBuildLastBuild[builder.index] and game.tick > global.blueBuildLastBuild[builder.index] + 11 then		
			if global.blueBuildToggle[builder.index] == true then
				-- Make magic happen.
				if bluebuild.build(builder) == true then
					global.blueBuildFirstTick[builder.index] = game.tick
					return
				end
			end
			if global.blueDemoToggle[builder.index] == true then
				--if global.blueLastDemo[builder.index] and game.tick > global.blueLastDemo[builder.index] + 5 then
					--global.blueLastDemo[builder.index] = game.tick
					-- Destructive magic happens here
					if bluebuild.demo(builder) == true then
						global.blueLastDemo[builder.index] = game.tick
						global.blueBuildLastBuild[builder.index] = game.tick	
						return
						--game.print("Last demo " .. global.blueLastDemo[builder.index] .. " current tick " .. game.tick)
						--global.blueBuildFirstTick[builder.index] = game.tick
						--global.blueLastDemo[builder.index] = game.tick
					end
				--end
			end
			--Still here?  Sleep for 6 ticks anyway.
			global.blueBuildFirstTick[builder.index] = game.tick
		end
	else
		-- Player moved.  Reset progress.
		global.bluePosition[builder.index] = pos
		global.blueBuildFirstTick[builder.index] = game.tick
	end
end

function bluebuild.build(builder)
	local pos = builder.position
	local reachDistance = math.max(math.min(builder.reach_distance, 128), 1)
	local searchArea = {{pos.x - reachDistance, pos.y - reachDistance}, {pos.x + reachDistance, pos.y + reachDistance}}
	-- Bluebuild 1.1 - Switch to a maintained list of ghosts instead of constant searching.
	-- if (not global.ghosts) or (not global.ghosts[builder.surface.name]) then
	-- 	return
	-- end
	--areaList = global.ghosts[builder.surface.name]
	local areaList = builder.surface.find_entities_filtered{area = searchArea, type = "entity-ghost", force=builder.force }
	--local tileList = builder.surface.find_entities_filtered{area = searchArea, type = "tile-ghost", force=builder.force }
	-- Merge the lists
	-- for key, value in pairs(tileList) do
	-- 	if not areaList then
	-- 		areaList = {}
	-- 	end
	-- 	table.insert(areaList, value)
	-- end
	-- game.print("Found " .. #areaList .. " ghosts in area.")
	--::liststart::
	for index, ghost in pairs(areaList) do
		-- if ghost == nil or not ghost.valid then
		-- 	table.remove(areaList, index)
		-- 	return false
		-- end
		--if builder.can_reach_entity(ghost) and builder.force == ghost.force then
		-- Need a fudge factor since my distance formula seems off.  Game likely measures from nearest colliding point?
		if distance(builder, ghost) < math.min(builder.build_distance + 1, 128) then
			-- game.print("Checking for items in inventory.")
			local materials = ghost.ghost_prototype.items_to_place_this
			local moduleList
			if ghost.type == "entity-ghost" then
				moduleList = ghost.item_requests --{"name"=..., "count"=...}
			end
			for __, item in pairs(materials) do
				if builder.get_item_count(__) > 0 then
					if ghost.type == "tile-ghost" then
						builder.remove_item({name=__})
						ghost.revive()
						return true
					end
					local tmp, revive = ghost.revive()
					-- game.print("Placing item " .. revive.name .. ".")
					if revive and revive.valid then
						for module, modulecount in pairs(moduleList) do
						-- game.print("moduleList == " .. moduleItem.item )
							if builder.get_item_count(module) > 0 then
								local modStack = {name=module, count=math.min(builder.get_item_count(module), modulecount)}
								revive.insert(modStack)
								builder.remove_item(modStack)
							end
						end
						--Anything that takes a recipe takes longer to build.
						if revive.type == "assembling-machine" then
							global.blueBuildLastBuild[builder.index] = game.tick + 60
						else
							global.blueBuildLastBuild[builder.index] = game.tick
						end
						
						-- game.print("Removing item from inventory.")
						script.raise_event(defines.events.on_put_item, {position=revive.position, player_index=builder.index, name="on_put_item"})
						script.raise_event(defines.events.on_built_entity, {created_entity=revive, player_index=builder.index, name="on_built_entity"})

						--table.remove(areaList, index)
						builder.remove_item({name=__})
						return true
					end
				end
			end
		end
	end
	-- Are we still here?
	return false
end		

function bluebuild.demo(builder)
	local pos = builder.position
	--local reachDistance = data.raw.player.player.reach_distance
	-- Reach distance must not be 0.  Just for you, Choumiko.  Now works with FAT Controller
	local reachDistance = math.max(math.min(builder.reach_distance, 128), 1)
	local searchArea = {{pos.x - reachDistance, pos.y - reachDistance}, {pos.x + reachDistance, pos.y + reachDistance}}
	local areaList = builder.surface.find_entities_filtered{area=searchArea, limit=100, force=builder.force}
	local treeList = builder.surface.find_entities_filtered{area=searchArea, limit=100, type="tree"}
	local rockList = builder.surface.find_entities_filtered{area=searchArea, limit=100, type="simple-entity"}
	local areaListCleaned = {}
	
	-- Clean areaList
	for index, ent in pairs(areaList) do
		if ent.to_be_deconstructed(builder.force) and builder.can_reach_entity(ent) then
			table.insert(areaListCleaned, ent)
		end
	end
	--Add trees and rocks.
	for index, ent in pairs(treeList) do
		if ent.to_be_deconstructed(builder.force) and builder.can_reach_entity(ent) then
			table.insert(areaListCleaned, ent)
		end
	end
	for index, ent in pairs(rockList) do
		if ent.to_be_deconstructed(builder.force) and builder.can_reach_entity(ent) then
			table.insert(areaListCleaned, ent)
		end
	end

	--game.print("Found " .. #areaListCleaned .. " demo targets in area.")
	--Now calculate mining time and destroy
	for index, ent in pairs(areaListCleaned) do
		if ent.name == "deconstructible-tile-proxy" then --In case we're trying to demo floor tiles.
			local tile = ent.surface.get_tile(ent.position)
			if builder.mine_tile(tile) then
				return true
			end
		end
		
		--Mining time is player... Nevermind, player.mining_power does not yet exist.  We'll just assume mining power of 2.5 (iron pickaxe)
		-- TODO: This is busted.  Everything is mining instantly!
		if ent.prototype.mineable_properties.mining_time * 60 + global.blueLastDemo[builder.index] < game.tick then
			-- This might all be obsolete now thanks to player.mine_entity(entity)
			--global.blueLastDemo[builder.index] = game.tick
			if builder.mine_entity(ent) then
				return true
			end	--Could not mine target for whatever reason.  Inventory probably full.
		end
	end
	--Don't check next tick.  This function is expensive.
	--return true

end

--Reinventing the wheel
function distance(ent1, ent2)
	return math.floor( math.sqrt( (ent1.position.x - ent2.position.x)^2 + (ent1.position.y - ent2.position.y)^2 ) )
end

-- function updateGhosts()
-- 	if not global.ghosts then
-- 		global.ghosts = {}
-- 	end
-- 	for __, surface in pairs(game.surfaces) do
-- 		-- type(surface) is string
-- 		if not global.ghosts[surface.name] then 
-- 			global.ghosts[surface.name] = {}
-- 		end
-- 		global.ghosts[surface.name] = game.surfaces[surface.name].find_entities_filtered{name="entity-ghost"}
-- 	end
-- end

function bluebuild.enable_autobuild(event)
	if event.created_entity and event.created_entity.valid and event.created_entity.name == "entity-ghost" then
		if global.blueBuildOptin[event.player_index] then
			-- if not global.ghosts[event.created_entity.surface.name] then 
			-- 	global.ghosts[event.created_entity.surface.name] = {}
			-- end
			-- table.insert(global.ghosts[event.created_entity.surface.name], event.created_entity)
			global.blueBuildToggle[event.player_index] = true
			global.blueBuildLastBuild[event.player_index] = game.tick
		end
	end
end

function bluebuild.demotoggle(event)
	if global.blueBuildOptin[event.player_index] then
		global.blueBuildLastBuild[event.player_index] = game.tick
		global.blueDemoToggle[event.player_index] = true
	end
end

commands.add_command("bluebuild", "Toggle bluebuild", function()
	global.blueBuildOptin[game.player.index] = not global.blueBuildOptin[game.player.index]
	if not global.blueBuildOptin[game.player.index] then
		global.blueBuildToggle[game.player.index] = false
		global.blueDemoToggle[game.player.index] = false
	end

	game.player.print("Bluebuild set to " .. tostring(global.blueBuildOptin[game.player.index]) .."." )
end)

commands.add_command("bluebuildswitch", "Toggle bluebuild for the whole server", function()
	if game.player.admin then
		global.blueBuildSwitch = not global.blueBuildSwitch
		game.player.print("Bluebuild server setting set to " .. tostring(global.blueBuildSwitch) .."." )
	else
		game.player.print("Only admins can use this command.")
	end
end)

Event.register(defines.events.on_built_entity, bluebuild.enable_autobuild)

Event.register(defines.events.on_player_created, bluebuild.initPlayer)
		
Event.register(defines.events.on_tick, bluebuild.playerloop)

Event.register(defines.events.on_marked_for_deconstruction, bluebuild.demotoggle)

Event.register(-1, bluebuild.runOnce)