-- Grid Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module devides the world in a grid, with a connecting piece inbetween.
require "grid_ore"


global.grid = global.grid or {}
global.grid.seed = 1
global.grid.size = 64
global.grid.x_border_width = 5
global.grid.y_border_width = 5
global.grid.x_bridge_width = 3 -- width * 1.5 ?? 
global.grid.y_bridge_width = 3

local function normalize(n) --keep numbers at (positive) 32 bits
	return n % 0x80000000
end

function grid_replace_tiles_in_chunk(area)
	local topleftx = area.left_top.x
	local toplefty = area.left_top.y
	local bottomrightx = area.right_bottom.x
	local bottomrighty = area.right_bottom.y
	local tileTable = {}
	for i=toplefty,bottomrighty do
		for j=topleftx,bottomrightx do
			for k=0,global.grid.x_border_width-1 do
				if(j % global.grid.size == k and 
				(((i+global.grid.size/2) % global.grid.size)-(math.floor(global.grid.x_bridge_width/2))) >= global.grid.x_bridge_width) then
					table.insert(tileTable,{ name = "out-of-map", position = {j, i}})
				end
			end
			for k=0,global.grid.y_border_width-1 do
				if(i % global.grid.size == k and 
				(((j+global.grid.size/2) % global.grid.size)-(math.floor(global.grid.y_bridge_width/2))) >= global.grid.y_bridge_width) then
					table.insert(tileTable,{ name = "out-of-map", position = {j, i}})
				end
			end
		end
	end
	game.surfaces["nauvis"].set_tiles(tileTable)
	grid_ore_generate_resources({x = topleftx, y=toplefty})
end

Event.register(defines.events.on_chunk_generated, function(event)
	grid_replace_tiles_in_chunk(event.area)
end)

Event.register(defines.events.on_player_created, function(event)
	local p = game.players[event.player_index]
	p.teleport({x = math.floor(global.grid.size/2), y = math.floor(global.grid.size/2)})
end)
-- Event.register(-1, function(event)
	-- --global.grid_module.seed = normalize(os.time())
	-- randomseed(global.grid_module.seed)
-- end)