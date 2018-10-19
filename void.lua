-- Void Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module randomly generates holes in the world to force players to adapt their designs to the world.

if MODULE_LIST then
	module_list_add("Swiss Cheese")
end

global.void = global.void or {}
global.void.seed = 1
global.void.tile_chance = 7
global.void.void_chance = 90

local function normalize(n) --keep numbers at (positive) 32 bits
	return n % 0x80000000
end

function void_replace_tiles_in_chunk(area)
	local topleftx = area.left_top.x
	local toplefty = area.left_top.y
	local bottomrightx = area.right_bottom.x
	local bottomrighty = area.right_bottom.y
	local tileTable = {}
	--Skip the starting chunk.
	if topleftx > -33 and bottomrightx < 1 and toplefty > -33 and bottomrighty < 1 then
		return
	end
	for i=toplefty,bottomrighty do
		for j=topleftx,bottomrightx do
			if(math.random(100) < global.void.tile_chance) then
				if(math.random(100) > global.void.void_chance) then
					table.insert(tileTable,{ name = "water", position = {j, i}})
				else 
					table.insert(tileTable,{ name = "out-of-map", position = {j, i}})
				end
			end
		end
	end
	game.surfaces["nauvis"].set_tiles(tileTable)
end

Event.register(defines.events.on_chunk_generated, function(event)
	void_replace_tiles_in_chunk(event.area)
end)

-- Event.register(defines.events.on_tick, function(event)
-- 	if(game.tick < 2)then
-- 		local tileTable = {}
-- 		for i=-8,8 do
-- 			for j= -8,8 do
-- 				table.insert(tileTable,{ name = "hazard-concrete-left", position = {j, i}})
-- 			end
-- 		end
-- 		game.surfaces["nauvis"].set_tiles(tileTable)
-- 	end
-- end)

Event.register(-1, function(event)
	global.void_module.seed = normalize(os.time())
	randomseed(global.void_module.seed)
end)