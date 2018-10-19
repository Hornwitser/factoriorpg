local surface = nil

local HOURS_OF_FUEL = 6

local SECONDS_PER_HOUR = 3600
local SECONDS_PER_FUEL = 200
local TOTAL_FUEL = HOURS_OF_FUEL * SECONDS_PER_HOUR / SECONDS_PER_FUEL

local function clear_area()
	for k, v in pairs(surface.find_entities({{-164, 0}, {163, 64}})) do
		v.destroy()
	end
end

local function make_immune(entity)
	entity.destructible = false
	entity.minable = false
end

local function create_entity_at(name, x, y, direction)
	local entity = surface.create_entity {
		name = name,
		position = { x, y }, 
		direction = direction,
		force = "player" }
	make_immune(entity)
	return entity
end

local function create_reactors()
	for _, x in pairs({ -3, 2 }) do
		for y = 0,7 do
			local nuke = create_entity_at("nuclear-reactor", x, y * 5 + 16 )
			nuke.get_inventory(defines.inventory.fuel).insert({ name="uranium-fuel-cell", count=2 })
		end
	end
end

local function create_requestors()
	for _, x in pairs({ -6, 5 }) do
		for y = 0,7 do
			local chest_x = x + 1
			local insert_dir = defines.direction.east
			local remove_dir = defines.direction.west
			if x < 0 then
				chest_x = x - 1
				insert_dir = defines.direction.west
				remove_dir = defines.direction.east
			end

			local chest = create_entity_at("logistic-chest-requester", chest_x, y * 5 + 16 - 1)
			chest.get_inventory(defines.inventory.chest).insert({ name="uranium-fuel-cell", count = TOTAL_FUEL - 2 })
			chest.set_request_slot({ name="uranium-fuel-cell", count=4 }, 1)

			create_entity_at("inserter", x, y * 5 + 16 - 1, insert_dir)

			create_entity_at("logistic-chest-storage", chest_x, y * 5 + 16 + 1)
			create_entity_at("inserter", x, y * 5 + 16 + 1, remove_dir)
		end
	end
end

local function create_inserter_power_poles()
	for _, x in pairs({ 8, -8 }) do
		for y = -2,0 do
			create_entity_at("substation", x, y * 18 + 40 + 14 )
		end
	end
end

local pipes_at_xs = { 5, -6 }
local pipes_at_ys = { 18, 28, 38, 48 } -- yes, technically the top most pipes are illegally placed under a substation... *sigh*

local function create_heat_pipes_at(start_x, y, direction)
	for x = start_x, start_x + (57 * direction), direction do
		create_entity_at("heat-pipe", x, y )
	end
end

local function create_heat_pipes()
	for _, x in pairs(pipes_at_xs) do
		local direction = 1
		if x < 0 then
			direction = -1
		end

		for _, y in pairs(pipes_at_ys) do
			create_heat_pipes_at(x, y, direction)
		end
	end
end

local function create_exchangers_at(start_x, y, direction, place_direction)
	for x = start_x, start_x + (48 * direction), direction * 3 do
		create_entity_at("heat-exchanger", x, y, place_direction)
	end
end

local function create_exchangers()
	for _, x in pairs(pipes_at_xs) do
		local direction = 1
		if x < 0 then
			direction = -1
		end

		for _, y in pairs(pipes_at_ys) do
			create_exchangers_at(x + (direction * 9), y - 1, direction, defines.direction.north)
			create_exchangers_at(x + (direction * 9), y + 2, direction, defines.direction.south)
		end
	end
end

local function create_pumps()
	for _, x in pairs(pipes_at_xs) do
		local direction = 1
		local pump_dir = defines.direction.west
		if x < 0 then
			direction = -1
			pump_dir = defines.direction.east
		end

		local pump_x = x + (direction * 6)

		for _, y in pairs(pipes_at_ys) do
			create_entity_at("offshore-pump", pump_x, y - 1, pump_dir)
			create_entity_at("offshore-pump", pump_x, y - 3, pump_dir)
			for p_y = y - 3, y - 1 do
				create_entity_at("pipe", pump_x + direction, p_y)
			end

			create_entity_at("offshore-pump", pump_x, y + 1, pump_dir)
			create_entity_at("offshore-pump", pump_x, y + 3, pump_dir)
			for p_y = y + 1, y + 3 do
				create_entity_at("pipe", pump_x + direction, p_y)
			end
		end
	end
end

local function create_steam_pipes()
	for _, x in pairs(pipes_at_xs) do
		local direction = 1
		if x < 0 then
			direction = -1
		end

		local start_x = x + (direction * 9)

		for _, y in pairs(pipes_at_ys) do
			for p_x = start_x, start_x + (direction * 50), direction do
				create_entity_at("pipe", p_x, y - 3)
				create_entity_at("pipe", p_x, y + 3)
			end

			for p_y = y - 3, y + 3 do
				create_entity_at("pipe", start_x + (direction * 51), p_y)
			end
		end
	end
end

local function create_turbines()
	for _, x in pairs(pipes_at_xs) do
		local direction = 1
		if x < 0 then
			direction = -1
		end

		local start_x = x + (direction * 63)

		for _, y in pairs(pipes_at_ys) do
			for p_x = 0,18 do
				for p_y = y - 3, y + 3, 3 do
					create_entity_at("steam-turbine", start_x + (direction * p_x * 5), p_y, defines.direction.west)
				end
			end
		end
	end
end

local poles_at_ys = { 20, 40 }
local pole_positions = {
	{ x =  72, y = 0 },
	{ x =  87, y = 4 },
	{ x = 102, y = 0 },
	{ x = 117, y = 4 },
	{ x = 132, y = 0 },
	{ x = 147, y = 4 }
}
local function create_turbine_power_poles()
	for _, x in pairs(pipes_at_xs) do
		local direction = 1
		local down_dir = defines.direction.west
		local up_dir = defines.direction.east
		if x < 0 then
			direction = -1
			down_dir = defines.direction.east
			up_dir = defines.direction.west
		end

		for _, y in pairs(poles_at_ys) do
			for _, pos in pairs(pole_positions) do
				for _, v in pairs(surface.find_entities({{x + (pos.x * direction), y + pos.y}, {x + (pos.x * direction) + 1, y + pos.y + 1}})) do
					v.destroy()

					create_entity_at("substation", x + (pos.x * direction) + (1 * direction), y + (pos.y / 4 * 3) + 2)
					create_entity_at("pipe-to-ground", x + (pos.x * direction) - (1 * direction), y + pos.y + 1, down_dir)
					create_entity_at("pipe-to-ground", x + (pos.x * direction) + (3 * direction), y + pos.y + 1, up_dir)
				end
			end

			for s_x = 0,3 do
				create_entity_at("substation", x + (s_x * 16 * direction) + (8 * direction), y + 3)
			end
		end
	end	
end

local function create_roboport()
	local port = create_entity_at("roboport", 9, 33)
	port.get_inventory(defines.inventory.roboport_robot).insert({ name="logistic-robot", count=25 })
end

local function create_radar()
	create_entity_at("radar", -9, 33)
end

local function create_fuel_source()
	create_entity_at("logistic-chest-active-provider", 1, 8)
end

local function create_outside_power_poles()
	for x = -5,5 do
		for _, y in pairs({8, 61}) do
			create_entity_at("big-electric-pole", x * 30, y)
		end
	end
end

local function connect_green_wire()
	local out_pole = surface.find_entity("big-electric-pole", {0, 8})
	local in_pole = surface.find_entity("substation", {8, 18})
	local chest = surface.find_entity("logistic-chest-requester", {6.5, 15.5})

	out_pole.connect_neighbour({
		wire = defines.wire_type.green,
		target_entity = in_pole
	})

	in_pole.connect_neighbour({
		wire = defines.wire_type.green,
		target_entity = chest
	})
end

local function set_tiles()
	local tiles = {}
	for x = -164,163 do
		for y = 0,59 do
			local tile = "grass-1"
			if (x <= -163 or x >= 162) and y >= 9 and y <= 59 then
				tile = "out-of-map"
			end

			if y == 9 or y == 58 or y == 10 or y == 59 then
				tile = "out-of-map"
			end

			table.insert(tiles, {name = tile, position = {x, y}})
		end
	end

	surface.set_tiles(tiles)
end

function prepare_base()
	surface = game.surfaces["nauvis"]

	clear_area()
	create_reactors()
	create_requestors()
	create_inserter_power_poles()

	create_heat_pipes()
	create_exchangers()
	create_pumps()
	create_steam_pipes()
	create_turbines()

	create_turbine_power_poles()

	create_roboport()
	create_radar()
	create_fuel_source()

	create_outside_power_poles()
	connect_green_wire()

	set_tiles()
end

function initialize(event)
	prepare_base()

	game.forces["player"].recipes["boiler"].enabled = false
	game.forces["player"].recipes["steam-engine"].enabled = false
	game.forces["player"].technologies["solar-energy"].enabled = false
	game.forces["player"].technologies["electric-energy-accumulators-1"].enabled = false
end

Event.register(-1, initialize)
