-- modular_admin Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module allows the admin tools to be easily expandable

--
--	At the bottom of this file there is a list of sub-modules you can enable.
--

--
--	VARIABLES
--

global.modular_admin = global.modular_admin or {}

global.modular_admin.use_sprite_button_open = true
global.modular_admin.use_sprite_button_close = false
global.modular_admin.sprite_button_open_sprite = "utility/side_menu_bonus_icon"
global.modular_admin.sprite_button_close_sprite = "utility/side_menu_bonus_icon"
global.modular_admin.sprite_button_open_tooltip = "Open Admin Menu"
global.modular_admin.sprite_button_close_tooltip = "Close Admin Menu"
global.modular_admin.button_open_caption = "Open Admin Menu"
global.modular_admin.button_close_caption = "Close Admin Menu"

global.modular_admin.raw = global.modular_admin.raw or {}
global.modular_admin.sorted = global.modular_admin.sorted or {}
global.modular_admin.visible = global.modular_admin.visible or {}
global.modular_admin.style = mod_gui.button_style
global.modular_admin.modules = global.modular_admin.modules or {} 

--
--	FUNCTIONS
--

function modular_admin_add_button(player_name, button)
	global.modular_admin.raw[player_name] = global.modular_admin.raw[player_name] or {}
	if button.name ~= nil then
		local nb = {}
		if button.caption ~= nil then
			nb.caption = button.caption
		else
			nb.caption = "NO CAPTION"
		end
		if button.order ~= nil then
			nb.order = button.order
		else
			nb.order = 10
		end
		if button.color ~= nil then
			nb.color = button.color
		else
			nb.color = {r = 1, g = 1, b = 1}
		end
		global.modular_admin.raw[player_name][button.name] = nb
		modular_admin_gui_changed(game.players[player_name])
	end
end

function modular_admin_remove_button(player_name, button_name)
	global.modular_admin.raw[player_name][button_name] = nil
	modular_admin_get_menu(game.players[player_name])[button_name].destroy()
end

function modular_admin_change_button_caption(player_name, button_name, caption)
	global.modular_admin.raw[player_name][button_name].caption = caption
	modular_admin_get_menu(game.players[player_name])[button_name].caption = caption
end

function modular_admin_change_button_color(player_name, button_name, color)
	global.modular_admin.raw[player_name][button_name].color = color
	modular_admin_get_menu(game.players[player_name])[button_name].style.font_color = color
end

function modular_admin_change_button_order(player_name, button_name, order)
	global.modular_admin.raw[player_name][button_name].order = order
	modular_admin_gui_changed(game.players[player_name])
end

function modular_admin_gui_changed(p)
	if p.admin then
		local bf = modular_admin_get_flow(p)
		if bf.modular_admin_menu_first ~= nil then
			bf = bf.modular_admin_menu_first
		else
			bf = bf.add {type = "frame", name = "modular_admin_menu_first", caption = "Admin Menu", direction = "vertical"}
		end
		if bf.modular_admin_menu ~= nil then
			bf.modular_admin_menu.destroy()
		end
		modular_admin_sort_table(p)
		bf.add {name = "modular_admin_menu", type = "flow", direction = "vertical", style = "slot_table_spacing_vertical_flow"}
		local tg = modular_admin_get_menu(p)
		for i, button in pairs(global.modular_admin.sorted[p.name]) do
			local b = tg.add {name=button.name, type="button", caption=button.caption}
			if button.color ~= nil then
				b.style.font_color = button.color
			end
			b.style.minimal_width = 275
		end
	end
end

function modular_admin_gui_toggle_visibility(p)
	global.modular_admin.visible[p.name] = global.modular_admin.visible[p.name] or false
	if global.modular_admin.visible[p.name] then
		global.modular_admin.visible[p.name] = false
		if global.modular_admin.use_sprite_button_open then
			topgui_add_button(p.name, {type="sprite-button", name = "modular_admin_toggle_button", sprite = global.modular_admin.sprite_button_open_sprite, tooltip=global.modular_admin.sprite_button_open_tooltip})
		else 
			topgui_add_button(p.name, {name = "modular_admin_toggle_button", caption = global.modular_admin.button_open_caption, color = {r=0, g=1, b=0}})
		end
	else
		global.modular_admin.visible[p.name] = true
		if global.modular_admin.use_sprite_button_close then
			topgui_add_button(p.name, {type="sprite-button", name = "modular_admin_toggle_button", sprite = global.modular_admin.sprite_button_close_sprite, tooltip=global.modular_admin.sprite_button_close_tooltip})
		else 
			topgui_add_button(p.name, {name = "modular_admin_toggle_button", caption = global.modular_admin.button_close_caption, color = {r=1, g=0, b=0}})
		end
	end
	local tg = modular_admin_get_flow(p)
	tg.style.visible = global.modular_admin.visible[p.name]
end


function modular_admin_sort_table(p)
	global.modular_admin.sorted[p.name] = {}
	for i, b in pairs(global.modular_admin.raw[p.name]) do
		local newtable = {name = i, caption = b.caption, order = b.order, color = b.color}
		table.insert(global.modular_admin.sorted[p.name], newtable)
	end
	table.sort(global.modular_admin.sorted[p.name], function(t1, t2)
			return t1.order < t2.order
		end)
	
end

function modular_admin_get_flow(p)
	local f = mod_gui.get_frame_flow(p).modular_admin_flow
	if f ~= nil then
		return f
	else 
		local mgff = mod_gui.get_frame_flow(p)
		local maf = mgff.add {type = "flow", name = "modular_admin_flow", direction = "horizontal"}
		maf.style.visible = global.modular_admin.visible[p.name]
		return maf
	end
end

function modular_admin_get_menu(p)
	local tg = modular_admin_get_flow(p).modular_admin_menu_first.modular_admin_menu
	if tg ~= nil then
		return tg
	end
	modular_admin_gui_changed(p)
	tg = modular_admin_get_flow(p).modular_admin_menu_first.modular_admin_menu
	return tg
end

function modular_admin_gui_clicked(event)
	if not (event and event.element and event.element.valid) then return end
	local i = event.player_index
	local p = game.players[i]
	local e = event.element
	if e ~= nil then
		if p.admin then
			if e.name == "modular_admin_toggle_button" then
				modular_admin_gui_toggle_visibility(p)
			end
		end
	end
end

function modular_admin_add_submodule(modulename)
	global.modular_admin.modules[modulename] = true
end

function modular_admin_remove_submodule(modulename)
	global.modular_admin.modules[modulename] = false
end
	
function modular_admin_submodule_state(mn)
	if global.modular_admin.modules[mn] ~= nil then
		return global.modular_admin.modules[mn]
	else
		return false
	end
end

--
--	EVENTS
--

Event.register(defines.events.on_player_joined_game, function(event)
	local p = game.players[event.player_index]
	if p.admin then
		global.modular_admin.raw[p.name] = global.modular_admin.raw[p.name] or {}
		global.modular_admin.visible[p.name] = global.modular_admin.visible[p.name] or false
		modular_admin_gui_changed(p)
		if global.modular_admin.visible[p.name] then
			if global.modular_admin.use_sprite_button_close then
				topgui_add_button(p.name, {type="sprite-button", name = "modular_admin_toggle_button", sprite = global.modular_admin.sprite_button_close_sprite, tooltip=global.modular_admin.sprite_button_close_tooltip})
			else 
				topgui_add_button(p.name, {name = "modular_admin_toggle_button", caption = global.modular_admin.button_close_caption, color = {r=1, g=0, b=0}})
			end
		else
			if global.modular_admin.use_sprite_button_open then
				topgui_add_button(p.name, {type="sprite-button", name = "modular_admin_toggle_button", sprite = global.modular_admin.sprite_button_open_sprite, tooltip=global.modular_admin.sprite_button_open_tooltip})
			else 
				topgui_add_button(p.name, {name = "modular_admin_toggle_button", caption = global.modular_admin.button_open_caption, color = {r=0, g=1, b=0}})
			end
		end
	end
end)

Event.register(defines.events.on_gui_click, modular_admin_gui_clicked)

--
--	SUB-MODULES
--
require "modular_admin_tag"
require "modular_admin_players"
require "modular_admin_spectate"
require "modular_admin_compensate"
require "modular_admin_ghosts"
--require "modular_admin_alert"
require "modular_admin_boost"