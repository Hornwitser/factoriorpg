-- char_mod (character_modification) Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module organizes the way in which the character bonuses are applied.

--
--	VARIABLES
--

global.char_mod = global.char_mod or {}
global.char_mod.enabled = global.char_mod.enabled or true
global.char_mod.apply_enabled = global.char_mod.apply_enabled or true
global.char_mod.bonus_list = {"character_crafting_speed_modifier", 
							"character_mining_speed_modifier",
							"character_running_speed_modifier",
							"character_build_distance_bonus",
							"character_item_drop_distance_bonus",
							"character_reach_distance_bonus",
							"character_resource_reach_distance_bonus",
							"character_item_pickup_distance_bonus",
							"character_loot_pickup_distance_bonus",
							"quickbar_count_bonus",
							"character_inventory_slots_bonus",
							"character_logistic_slot_count_bonus",
							"character_trash_slot_count_bonus",
							"character_maximum_following_robot_count_bonus",
							"character_health_bonus"}
--INT (not dynamically generated these values due to different min / max values )

global.char_mod.character_crafting_speed_modifier = global.char_mod.character_crafting_speed_modifier or {}
global.char_mod.character_crafting_speed_modifier.val = global.char_mod.character_crafting_speed_modifier.val or {}
global.char_mod.character_crafting_speed_modifier.fin = global.char_mod.character_crafting_speed_modifier.fin or {}
global.char_mod.character_crafting_speed_modifier.info = {data = "double", minimum = -1, maximum = 100}

global.char_mod.character_mining_speed_modifier = global.char_mod.character_mining_speed_modifier or {}
global.char_mod.character_mining_speed_modifier.val = global.char_mod.character_mining_speed_modifier.val or {}
global.char_mod.character_mining_speed_modifier.fin = global.char_mod.character_mining_speed_modifier.fin or {}
global.char_mod.character_mining_speed_modifier.info = {data = "double", minimum = -1, maximum = 100}

global.char_mod.character_running_speed_modifier = global.char_mod.character_running_speed_modifier or {}
global.char_mod.character_running_speed_modifier.val = global.char_mod.character_running_speed_modifier.val or {}
global.char_mod.character_running_speed_modifier.fin = global.char_mod.character_running_speed_modifier.fin or {}
global.char_mod.character_running_speed_modifier.info = {data = "double", minimum = -1, maximum = 100}

global.char_mod.character_build_distance_bonus = global.char_mod.character_build_distance_bonus or {}
global.char_mod.character_build_distance_bonus.val = global.char_mod.character_build_distance_bonus.val or {}
global.char_mod.character_build_distance_bonus.fin = global.char_mod.character_build_distance_bonus.fin or {}
global.char_mod.character_build_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.char_mod.character_item_drop_distance_bonus = global.char_mod.character_item_drop_distance_bonus or {}
global.char_mod.character_item_drop_distance_bonus.val = global.char_mod.character_item_drop_distance_bonus.val or {}
global.char_mod.character_item_drop_distance_bonus.fin = global.char_mod.character_item_drop_distance_bonus.fin or {}
global.char_mod.character_item_drop_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.char_mod.character_reach_distance_bonus = global.char_mod.character_reach_distance_bonus or {}
global.char_mod.character_reach_distance_bonus.val = global.char_mod.character_reach_distance_bonus.val or {}
global.char_mod.character_reach_distance_bonus.fin = global.char_mod.character_reach_distance_bonus.fin or {}
global.char_mod.character_reach_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.char_mod.character_resource_reach_distance_bonus = global.char_mod.character_resource_reach_distance_bonus or {}
global.char_mod.character_resource_reach_distance_bonus.val = global.char_mod.character_resource_reach_distance_bonus.val or {}
global.char_mod.character_resource_reach_distance_bonus.fin = global.char_mod.character_resource_reach_distance_bonus.fin or {}
global.char_mod.character_resource_reach_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.char_mod.character_item_pickup_distance_bonus = global.char_mod.character_item_pickup_distance_bonus or {}
global.char_mod.character_item_pickup_distance_bonus.val = global.char_mod.character_item_pickup_distance_bonus.val or {}
global.char_mod.character_item_pickup_distance_bonus.fin = global.char_mod.character_item_pickup_distance_bonus.fin or {}
global.char_mod.character_item_pickup_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.char_mod.character_loot_pickup_distance_bonus = global.char_mod.character_loot_pickup_distance_bonus or {}
global.char_mod.character_loot_pickup_distance_bonus.val = global.char_mod.character_loot_pickup_distance_bonus.val or {}
global.char_mod.character_loot_pickup_distance_bonus.fin = global.char_mod.character_loot_pickup_distance_bonus.fin or {}
global.char_mod.character_loot_pickup_distance_bonus.info = {data = "double", minimum = 0, maximum = 100}

global.char_mod.quickbar_count_bonus = global.char_mod.quickbar_count_bonus or {}
global.char_mod.quickbar_count_bonus.val = global.char_mod.quickbar_count_bonus.val or {}
global.char_mod.quickbar_count_bonus.fin = global.char_mod.quickbar_count_bonus.fin or {}
global.char_mod.quickbar_count_bonus.info = {data = "int", minimum = 0, maximum = 10}

global.char_mod.character_inventory_slots_bonus = global.char_mod.character_inventory_slots_bonus or {}
global.char_mod.character_inventory_slots_bonus.val = global.char_mod.character_inventory_slots_bonus.val or {}
global.char_mod.character_inventory_slots_bonus.fin = global.char_mod.character_inventory_slots_bonus.fin or {}
global.char_mod.character_inventory_slots_bonus.info = {data = "int", minimum = 0, maximum = 100}

global.char_mod.character_logistic_slot_count_bonus = global.char_mod.character_logistic_slot_count_bonus or {}
global.char_mod.character_logistic_slot_count_bonus.val = global.char_mod.character_logistic_slot_count_bonus.val or {}
global.char_mod.character_logistic_slot_count_bonus.fin = global.char_mod.character_logistic_slot_count_bonus.fin or {}
global.char_mod.character_logistic_slot_count_bonus.info =  {data = "int", minimum = 0, maximum = 50}

global.char_mod.character_trash_slot_count_bonus = global.char_mod.character_trash_slot_count_bonus or {}
global.char_mod.character_trash_slot_count_bonus.val = global.char_mod.character_trash_slot_count_bonus.val or {}
global.char_mod.character_trash_slot_count_bonus.fin = global.char_mod.character_trash_slot_count_bonus.fin or {}
global.char_mod.character_trash_slot_count_bonus.info = {data = "int", minimum = 0, maximum = 50}

global.char_mod.character_maximum_following_robot_count_bonus = global.char_mod.character_maximum_following_robot_count_bonus or {}
global.char_mod.character_maximum_following_robot_count_bonus.val = global.char_mod.character_maximum_following_robot_count_bonus.val or {}
global.char_mod.character_maximum_following_robot_count_bonus.fin = global.char_mod.character_maximum_following_robot_count_bonus.fin or {}
global.char_mod.character_maximum_following_robot_count_bonus.info = {data = "int", minimum = 0, maximum = 500}

global.char_mod.character_health_bonus = global.char_mod.character_health_bonus or {}
global.char_mod.character_health_bonus.val = global.char_mod.character_health_bonus.val or {}
global.char_mod.character_health_bonus.fin = global.char_mod.character_health_bonus.fin or {}
global.char_mod.character_health_bonus.info = {data = "int", minimum = 0, maximum = 50000}

--
--	FuNCTIONS
--
function char_mod_table_search(tbl, val)
	if tbl ~= nil then
		for i, str in pairs(tbl) do
			if str == val then
				return true
			end
		end
	end
	return false
end

function char_mod_enable()
	return false --Not Implemented
end

function char_mod_disable()
	return false --Not Implemented
end

function char_mod_apply_bonus(p, b)
	if char_mod_table_search(global.char_mod.bonus_list, b) then
		if global.char_mod[b].val[p.name] ~= nil then
			char_mod_calculate_bonus(p, b, true)
			if p.connected and (p.character ~= nil) then
				p[b] = global.char_mod[b].fin[p.name]
			end
		end
	else
		return false -- bonus not found
	end
end

function char_mod_calculate_bonus(p, b, bypass)
	if bypass or char_mod_table_search(global.char_mod.bonus_list, b) then
		if bypass or (global.char_mod[b].val[p.name] ~= nil) then
			local add = {}
			local mul = {}
			local div = {}
			for name, tbl in pairs(global.char_mod[b].val[p.name]) do
				if tbl.op == "add" then
					table.insert(add, tbl.val)
				elseif tbl.op == "sub" then
					table.insert(add, tbl.val)
				elseif tbl.op == "mul" then
					table.insert(mul, tbl.val)
				elseif tbl.op == "div" then
					table.insert(div, tbl.val)
				end
			end
			local total = 0
			for _, s in pairs(add) do
				total = total + s
			end
			for _, m in pairs(mul) do
				total = total * m
			end
			for _, d in pairs(div) do
				total = total / d
			end
			if total < global.char_mod[b].info.minimum then
				total = global.char_mod[b].info.minimum
			end
			if total > global.char_mod[b].info.maximum then
				total = global.char_mod[b].info.maximum
			end
			if global.char_mod[b].info.data == "int" then
				total = math.floor(total)
			end
			global.char_mod[b].fin[p.name] = total
		end
	else
		return false -- bonus not found
	end
end

function char_mod_apply_all_bonus(p)
	for i, b in pairs (global.char_mod.bonus_list) do
		char_mod_apply_bonus(p, b)
	end
end

function char_mod_calculate_finals(p)
	for i, b in pairs (global.char_mod.bonus_list) do
		char_mod_calculate_bonus(p, b, false)
	end
end

function char_mod_add_bonus(p, b, d)
	if char_mod_table_search(global.char_mod.bonus_list, b) then
		global.char_mod[b].val[p.name] = global.char_mod[b].val[p.name] or {}
		local r = {}
		if d.name ~= nil then
			r.name = d.name -- table index is nil
		else
			r.name = "unknown"
		end
		if d.op ~= nil then
			r.op = d.op
		else
			r.op = "add"
		end
		if d.val ~= nil then
			r.val = d.val
		else
			if r.op == "add" or r.op == "sub" then
				r.val = 0
			elseif r.op == "mul" or r.op == "div" then
				r.val = 1
			else
				return false
			end
		end
		global.char_mod[b].val[p.name][r.name] = {op = r.op, val = r.val}
		char_mod_apply_bonus(p, b)
	else
		return false -- bonus not found
	end
end

-- Kinda not needed since add also replaces if exists
-- function char_mod_change_bonus(p, b, d)
	-- return false
-- end

function char_mod_remove_bonus(p, b, e)
	if char_mod_table_search(global.char_mod.bonus_list, b) then
		if global.char_mod[b].val[p.name] ~= nil then
			if global.char_mod[b].val[p.name][e] ~= nil then
				global.char_mod[b].val[p.name][e] = nil
				char_mod_apply_bonus(p, b)
				return true
			end
		end
	end
	return false
end

function char_mod_get_bonus(p, b)
	return global.char_mod[b].val[p.name]
end

function char_mod_get_final_bonus(p, b)
	return global.char_mod[b].fin[p.name]
end

--
-- Events
--

Event.register(defines.events.on_player_joined_game, function(event)
	local p = game.players[event.player_index]
	char_mod_apply_all_bonus(p)
end)