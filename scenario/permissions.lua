-- Permissions Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module sets the permissions in the way we want them to be.


-- global.permissions.action_list_default = {
	--{action = defines.input_action.nothing, value = true},
	-- {action = defines.input_action.change_picking_state, value = true},
	-- {action = defines.input_action.drop_item, value = true},
	-- {action = defines.input_action.build_item, value = true},
	-- {action = defines.input_action.start_walking, value = true},
	-- {action = defines.input_action.stop_walking, value = true},
	-- {action = defines.input_action.begin_mining, value = true},
	-- {action = defines.input_action.begin_mining_terrain, value = true},
	-- {action = defines.input_action.stop_mining, value = true},
	-- {action = defines.input_action.rotate_entity, value = true},
	-- {action = defines.input_action.reverse_rotate_entity, value = true},
	-- {action = defines.input_action.toggle_driving, value = true},
	-- {action = defines.input_action.change_riding_state, value = true},
	-- {action = defines.input_action.open_gui, value = true},
	-- {action = defines.input_action.open_item, value = true},
	-- {action = defines.input_action.close_gui, value = true},
	-- {action = defines.input_action.open_character_gui, value = true},
	-- {action = defines.input_action.cursor_transfer, value = true},
	-- {action = defines.input_action.cursor_split, value = true},
	-- {action = defines.input_action.stack_transfer, value = true},
	-- {action = defines.input_action.inventory_transfer, value = true},
	-- {action = defines.input_action.check_c_r_c_heuristic, value = true},
	-- {action = defines.input_action.craft, value = true},
	-- {action = defines.input_action.wire_dragging, value = true},
	-- {action = defines.input_action.connect_rolling_stock, value = true},
	-- {action = defines.input_action.disconnect_rolling_stock, value = true},
	-- {action = defines.input_action.change_shooting_state, value = true},
	-- {action = defines.input_action.toggle_entity_on_off_state, value = true},
	-- {action = defines.input_action.setup_assembling_machine, value = true},
	-- {action = defines.input_action.selected_entity_changed, value = true},
	-- {action = defines.input_action.selected_entity_changed_very_close, value = true},
	-- {action = defines.input_action.selected_entity_changed_very_close_precise, value = true},
	-- {action = defines.input_action.selected_entity_changed_relative, value = true},
	-- {action = defines.input_action.selected_entity_changed_based_on_unit_number, value = true},
	-- {action = defines.input_action.selected_entity_cleared, value = true},
	-- {action = defines.input_action.shortcut_quick_bar_transfer, value = true},
	-- {action = defines.input_action.clean_cursor_stack, value = true},
	-- {action = defines.input_action.smart_pipette, value = true},
	-- {action = defines.input_action.select_item, value = true},
	-- {action = defines.input_action.reset_assembling_machine, value = true},
	-- {action = defines.input_action.select_gun, value = true},
	-- {action = defines.input_action.stack_split, value = true},
	-- {action = defines.input_action.inventory_split, value = true},
	-- {action = defines.input_action.cancel_craft, value = true},
	-- {action = defines.input_action.set_filter, value = true},
	-- {action = defines.input_action.set_autosort_inventory, value = true},
	-- {action = defines.input_action.check_c_r_c, value = true},
	-- {action = defines.input_action.open_technology_gui, value = true},
	-- {action = defines.input_action.set_circuit_condition, value = true},
	-- {action = defines.input_action.set_signal, value = true},
	-- {action = defines.input_action.start_research, value = true},
	-- {action = defines.input_action.cancel_research, value = true},
	-- {action = defines.input_action.change_arithmetic_combinator_parameters, value = true},
	-- {action = defines.input_action.change_decider_combinator_parameters, value = true},
	-- {action = defines.input_action.change_programmable_speaker_parameters, value = true},
	-- {action = defines.input_action.change_programmable_speaker_alert_parameters, value = true},
	-- {action = defines.input_action.change_programmable_speaker_circuit_parameters, value = true},
	-- {action = defines.input_action.set_inserter_max_stack_size, value = true},
	-- {action = defines.input_action.launch_rocket, value = true},
	-- {action = defines.input_action.set_logistic_filter_item, value = true},
	-- {action = defines.input_action.set_logistic_trash_filter_item, value = true},
	-- {action = defines.input_action.set_logistic_filter_signal, value = true},
	-- {action = defines.input_action.switch_constant_combinator_state, value = true},
	-- {action = defines.input_action.switch_power_switch_state, value = true},
	-- {action = defines.input_action.switch_connect_to_logistic_network, value = true},
	-- {action = defines.input_action.set_circuit_mode_of_operation, value = true},
	-- {action = defines.input_action.set_behavior_mode, value = true},
	-- {action = defines.input_action.fast_entity_transfer, value = true},
	-- {action = defines.input_action.fast_entity_split, value = true},
	-- {action = defines.input_action.gui_click, value = true},
	-- {action = defines.input_action.write_to_console, value = true},
	-- {action = defines.input_action.market_offer, value = true},
	-- {action = defines.input_action.edit_train_schedule, value = true},
	-- {action = defines.input_action.set_train_stopped, value = true},
	-- {action = defines.input_action.change_train_stop_station, value = true},
	-- {action = defines.input_action.change_active_item_group_for_crafting, value = true},
	-- {action = defines.input_action.set_use_item_groups, value = true},
	-- {action = defines.input_action.change_controller_speed, value = true},
	-- {action = defines.input_action.gui_text_changed, value = true},
	-- {action = defines.input_action.gui_checked_state_changed, value = true},
	-- {action = defines.input_action.gui_selection_state_changed, value = true},
	-- {action = defines.input_action.place_equipment, value = true},
	-- {action = defines.input_action.take_equipment, value = true},
	-- {action = defines.input_action.use_ability, value = true},
	-- {action = defines.input_action.use_item, value = true},
	-- {action = defines.input_action.change_active_quick_bar, value = true},
	-- {action = defines.input_action.close_blueprint_record, value = true},
	-- {action = defines.input_action.close_blueprint_book, value = true},
	-- {action = defines.input_action.open_blueprint_library_gui, value = true},
	-- {action = defines.input_action.open_blueprint_record, value = true},
	-- {action = defines.input_action.craft_blueprint_record, value = true},
	-- {action = defines.input_action.drop_blueprint_record, value = true},
	-- {action = defines.input_action.grab_blueprint_record, value = true},
	-- {action = defines.input_action.delete_blueprint_record, value = true},
	-- {action = defines.input_action.create_blueprint_like, value = true},
	-- {action = defines.input_action.create_blueprint_like_stack_transfer, value = true},
	-- {action = defines.input_action.cancel_drop_blueprint_record, value = true},
	-- {action = defines.input_action.open_production_gui, value = true},
	-- {action = defines.input_action.open_kills_gui, value = true},
	-- {action = defines.input_action.set_inventory_bar, value = true},
	-- {action = defines.input_action.change_active_item_group_for_filters, value = true},
	-- {action = defines.input_action.move_on_zoom, value = true},
	-- {action = defines.input_action.start_repair, value = true},
	-- {action = defines.input_action.stop_repair, value = true},
	-- {action = defines.input_action.select_blueprint_entities, value = true},
	-- {action = defines.input_action.alt_select_blueprint_entities, value = true},
	-- {action = defines.input_action.setup_blueprint, value = true},
	-- {action = defines.input_action.setup_single_blueprint_record, value = true},
	-- {action = defines.input_action.deconstruct, value = true},
	-- {action = defines.input_action.cancel_deconstruct, value = true},
	-- {action = defines.input_action.set_blueprint_icon, value = true},
	-- {action = defines.input_action.set_single_blueprint_record_icon, value = true},
	-- {action = defines.input_action.change_single_blueprint_record_label, value = true},
	-- {action = defines.input_action.update_blueprint_shelf, value = true},
	-- {action = defines.input_action.transfer_blueprint, value = true},
	-- {action = defines.input_action.transfer_blueprint_immediately, value = true},
	-- {action = defines.input_action.change_blueprint_book_record_label, value = true},
	-- {action = defines.input_action.cancel_new_blueprint, value = true},
	-- {action = defines.input_action.copy_entity_settings, value = true},
	-- {action = defines.input_action.paste_entity_settings, value = true},
	-- {action = defines.input_action.multiplayer_init, value = true},
	-- {action = defines.input_action.custom_input, value = true},
	-- {action = defines.input_action.remove_cables, value = true},
	-- {action = defines.input_action.clear_blueprint, value = true},
	-- {action = defines.input_action.export_blueprint, value = true},
	-- {action = defines.input_action.import_blueprint, value = true},
	-- {action = defines.input_action.toggle_show_entity_info, value = true},
	-- {action = defines.input_action.player_join_game, value = true},
	-- {action = defines.input_action.player_leave_game, value = true},
	-- {action = defines.input_action.set_allow_commands, value = true},
	-- {action = defines.input_action.set_research_finished_stops_game, value = true},
	-- {action = defines.input_action.build_terrain, value = true},
	-- {action = defines.input_action.change_train_wait_condition, value = true},
	-- {action = defines.input_action.change_train_wait_condition_data, value = true},
	-- {action = defines.input_action.change_item_label, value = true},
	-- {action = defines.input_action.build_rail, value = true},
	-- {action = defines.input_action.open_train_gui, value = true},
	-- {action = defines.input_action.open_train_station_gui, value = true},
	-- {action = defines.input_action.switch_to_rename_stop_gui, value = true},
	-- {action = defines.input_action.open_bonus_gui, value = true},
	-- {action = defines.input_action.open_trains_gui, value = true},
	-- {action = defines.input_action.open_achievements_gui, value = true},
	-- {action = defines.input_action.open_tutorials_gui, value = true},
	-- {action = defines.input_action.select_area, value = true},
	-- {action = defines.input_action.alt_select_area, value = true},
	-- {action = defines.input_action.server_command, value = true},
	-- {action = defines.input_action.open_logistic_gui, value = true},
	-- {action = defines.input_action.set_entity_color, value = true},
	-- {action = defines.input_action.clear_selected_blueprint, value = true},
	-- {action = defines.input_action.cycle_blueprint_book_forwards, value = true},
	-- {action = defines.input_action.cycle_blueprint_book_backwards, value = true},
	-- {action = defines.input_action.stop_movement_in_the_next_tick, value = true},
	-- {action = defines.input_action.toggle_enable_vehicle_logistics_while_moving, value = true},
	-- {action = defines.input_action.open_equipment, value = true},
	-- {action = defines.input_action.select_entity_slot, value = true},
	-- {action = defines.input_action.toggle_deconstruction_item_entity_filter_mode, value = true},
	-- {action = defines.input_action.toggle_deconstruction_item_tile_filter_mode, value = true},
	-- {action = defines.input_action.set_deconstruction_item_trees_only, value = true},
	-- {action = defines.input_action.set_deconstruction_item_tile_selection_mode, value = true},
	-- {action = defines.input_action.mod_settings_changed, value = true},
	-- {action = defines.input_action.set_entity_energy_property, value = true},
	-- {action = defines.input_action.set_auto_launch_rocket, value = true},
	-- {action = defines.input_action.drop_to_blueprint_book, value = true},
	-- {action = defines.input_action.clear_selected_deconstruction_item, value = true},
	-- {action = defines.input_action.edit_custom_tag, value = true},
	-- {action = defines.input_action.delete_custom_tag, value = true},
	-- {action = defines.input_action.toggle_connect_front_center_tank, value = true},
	-- {action = defines.input_action.toggle_connect_center_back_tank, value = true},
	-- {action = defines.input_action.select_tile_slot, value = true},
	-- {action = defines.input_action.add_permission_group, value = true},
	-- {action = defines.input_action.delete_permission_group, value = true},
	-- {action = defines.input_action.edit_permission_group, value = true},
	-- {action = defines.input_action.import_blueprint_string, value = true},
	-- {action = defines.input_action.gui_elem_selected, value = true},
-- } 

global.permissions = global.permissions or {}
global.permissions.groups = global.permissions.groups or {}

-- GROUP DEFINITIONS:
global.permissions.groups.normal = {name = "normal", permissions = {{action = defines.input_action.deconstruct, value = false},

	{action = defines.input_action.launch_rocket, value = false},
	{action = defines.input_action.set_auto_launch_rocket, value = false},

	{action = defines.input_action.add_permission_group, value = false},
	{action = defines.input_action.delete_permission_group, value = false},
	{action = defines.input_action.edit_permission_group, value = false},
	{action = defines.input_action.server_command, value = false},
	{action = defines.input_action.set_allow_commands, value = false},

	{action = defines.input_action.cancel_research, value = false},

	{action = defines.input_action.open_trains_gui, value = false},
	{action = defines.input_action.open_train_gui, value = false},
	{action = defines.input_action.switch_to_rename_stop_gui, value = false},
	{action = defines.input_action.set_entity_color, value = false},

	{action = defines.input_action.open_tutorials_gui, value = false},

	{action = defines.input_action.change_programmable_speaker_parameters, value = false},
	{action = defines.input_action.change_programmable_speaker_alert_parameters, value = false},
	{action = defines.input_action.change_programmable_speaker_circuit_parameters, value = false},

	{action = defines.input_action.edit_custom_tag, value = false},
	{action = defines.input_action.delete_custom_tag, value = false},
}}

global.permissions.groups.trusted = {name = "trusted", permissions = {
	{action = defines.input_action.launch_rocket, value = false},
	{action = defines.input_action.set_auto_launch_rocket, value = false},

	{action = defines.input_action.add_permission_group, value = false},
	{action = defines.input_action.delete_permission_group, value = false},
	{action = defines.input_action.edit_permission_group, value = false},
	{action = defines.input_action.server_command, value = false},
	{action = defines.input_action.set_allow_commands, value = false},

	{action = defines.input_action.open_tutorials_gui, value = false},

}}

global.permissions.groups.patreons = {name = "patreons", permissions = {
	{action = defines.input_action.add_permission_group, value = false},
	{action = defines.input_action.delete_permission_group, value = false},
	{action = defines.input_action.edit_permission_group, value = false},
	{action = defines.input_action.server_command, value = false},
	{action = defines.input_action.set_allow_commands, value = false},

	{action = defines.input_action.open_tutorials_gui, value = false},

}}

global.permissions.groups.admins = {name = "admins", permissions = {
	{action = defines.input_action.open_tutorials_gui, value = false}
}}

-- PERMISSIONS IMPLEMENTATION
function permissions_init()
	for i, group in pairs(global.permissions.groups) do
		game.permissions.create_group(group.name)
		if group.permissions then
			for j, permission in pairs(group.permissions) do
				game.permissions.get_group(group.name).set_allows_action(permission.action, permission.value)
			end
		end
	end
end

function permissions_add_playername(name, group)
	local player = game.players[player_name]
	permission_add_player(player, group)
end

function permissions_add_player(player, group)
	game.permissions.get_group(group).add_player(player)
end

function permissions_remove_playername(name, group)
	local player = game.players[player_name]
	permission_remove_player(player, group)
end

function permissions_remove_player(player, group)
	game.permissions.get_group(group).remove_player(player)
end

local events = {}
events[defines.events.on_player_joined_game] = function(event)
	local player = game.players[event.player_index]
	if(global.permissions)then
		permissions_add_player(player, "normal")
	end
end

return {
	events = events,
	on_init = permissions_init,
}