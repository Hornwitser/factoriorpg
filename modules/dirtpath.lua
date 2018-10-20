DIRT_THRESHOLD = 10

if MODULE_LIST then
	module_list_add("Dirt Path")
end

--This is all subjective.
DIRT= {
	["grass-1"]="grass-3",
	["grass-2"]="grass-3",
	["grass-3"]="grass-4",
	["grass-4"]="dirt-4",
	["dirt-4"]="dirt-6",
	["dirt-6"]="dirt-7",
	["dirt-7"]="dirt-5",
	["dirt-5"]="dirt-3",
	["dirt-3"]="dirt-2",
	["dirt-2"]="dirt-1",
	["dirt-1"]="red-desert-3",
	["red-desert-3"]="sand-3",

	["red-desert-0"]="red-desert-1",
	["red-desert-1"]="red-desert-2",
	["red-desert-2"]="red-desert-3"
}

global.dirt = {}

function dirtDirt(event)
	--for __, p in pairs(game.connected_players) do
		local p = game.players[event.player_index]
	
		-- Trains aren't cars!  This breaks it.  Dunno why they're handled differently.
		--if p.walking_state.walking or (p.driving and p.vehicle.speed ~= 0) then
		-- Special conditional check for Factorissimo
		if p.walking_state.walking or (p.vehicle and p.vehicle.type == "car" and p.vehicle.speed ~= 0) then
			local tile = p.surface.get_tile(p.position)
			if not (tile.hidden_tile or string.find(tile.name, "concrete")) then
				
				--game.print("Dirt value now at: ".. global.dirt[tile.position.x][tile.position.y])
				--if global.dirt[tile.position.x][tile.position.y] >= DIRT_THRESHOLD then
					--game.print("Converting patch to dirt.")
					
					-- No longer necessary for 0.16
					-- Check for waterfix, else prevent exploit
					-- local waterfix = false
					-- if game.active_mods["water-fix"] then
					-- 	waterfix = true
					-- end
					-- -- for module, version in pairs(game.active_mods) do
					-- 	-- if module == "water-fix" then
					-- 		-- waterfix = true
					-- 	-- end
					-- -- end
					-- if not waterfix then
					-- -- Check for water to prevent landfill exploit
					-- 	for xx = -1, 2 do
					-- 		for yy = -1, 2 do
					-- 			local waterCheck = p.surface.get_tile(tile.position.x + xx, tile.position.y + yy)
					-- 			if not waterCheck or not waterCheck.valid or waterCheck.collides_with("water-tile") then
					-- 				return
					-- 			end
					-- 		end
					-- 	end
					-- end

					dirtAdd(tile.position.x, tile.position.y) --Wear the center tile out one additional step.
					local dirt = {}
					for xx = -1, 1 do
					 	for yy = -1, 1 do
							if not (math.abs(xx) == math.abs(yy)) or xx == 0 then
								-- Check twice at xx == 0, yy == 0
								if dirtAdd(tile.position.x + xx, tile.position.y + yy) then

									local validTile = p.surface.get_tile(tile.position.x + xx, tile.position.y + yy)
									if not validTile.collides_with("water-tile") and not validTile.hidden_tile and not string.find(validTile.name, "sand") then
										local newtile = DIRT[validTile.name] or "dirt-6"
										table.insert(dirt, {name=newtile, position={tile.position.x+xx, tile.position.y+yy}})
									end
								end
							end
						end
					end
					if #dirt > 0 then
						p.surface.set_tiles(dirt)
					end
				--end
			end
		end
	--end
end

function dirtAdd(x, y)
	local key = x .. "," .. y
	if global.dirt[key] then
		global.dirt[key] = global.dirt[key] + 1
	else	
		global.dirt[key] = 1
	end
	if global.dirt[key] >= DIRT_THRESHOLD then
		global.dirt[key] = 0
		return true
	end
end

function cleanDirt()
	if not global.dirt then
		log("Dirt Path not initialized!")
		return
	end
	for k, v in pairs(global.dirt) do
		global.dirt[k] = global.dirt[k] - 1
		if global.dirt[k] <= 0 then
			global.dirt[k] = nil
		end
	end
end

function dirt_handler(event)
	-- if event.tick % 30 == 0 then
	-- 	dirtDirt()
	-- end
	--if (event.tick) % (60 * 2) == 0 then -- debug
	if (event.tick+500) % (60 * 60 * 30) == 0 then
		cleanDirt()
	end
end

--Since the migration failed:
--Migration from 1.1.1
script.on_configuration_changed(function()
	if not global.flattening then
		global.flattening = true
		global.dirt = {}
	end
end)

Event.register(-108000, cleanDirt) --30 minutes
Event.register(defines.events.on_player_changed_position, dirtDirt)
