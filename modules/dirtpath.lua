DIRT_THRESHOLD = 10

if MODULE_LIST then
	module_list_add("Dirt Path")
end
DIRT_THRESHOLD = 15

--This is all subjective.
DIRT = {
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
	["red-desert-2"]="red-desert-3",

	DEFAULT = "dirt-6"
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
				dirtAdd(tile.position.x, tile.position.y, 2) --Wear the center tile out two additional steps.
				--local dirt = {}
				for xx = -1, 1 do
					for yy = -1, 1 do
						if not (math.abs(xx) == math.abs(yy)) or xx == 0 then
							--dirtAdd(tile)
							if dirtAdd(tile.position.x + xx, tile.position.y + yy) then
								local validTile = p.surface.get_tile(tile.position.x + xx, tile.position.y + yy)
								if not validTile.collides_with("water-tile") and not validTile.hidden_tile and not string.find(validTile.name, "sand") then
									local newtile = DIRT[validTile.name] or DIRT.DEFAULT
									table.insert(dirt, {name=newtile, position={tile.position.x+xx, tile.position.y+yy}})
								end
							end
						end
					end
				end
				if #dirt > 0 then
					p.surface.set_tiles(dirt)
					--Remove decals
					for _, tile in pairs(dirt) do
						local area = {{tile.position.x, tile.position.y}, {tile.position.x, tile.position.y}}
						local decals = p.surface.find_entities_filtered{area=area, type="decal"}
						for __, decal in pairs(decals) do
							decal.destroy()
						end
					end
				end
			end
		end
	--end
end

function dirtAdd(tile, amount)
	local key = tile.position.x .. "," .. tile.position.y
	amount = amount or 1
	if global.dirt[key] then
		global.dirt[key] = global.dirt[key] + amount
	else	
		global.dirt[key] = amount
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
