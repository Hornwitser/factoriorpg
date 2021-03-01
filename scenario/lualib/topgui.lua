-- topgui Module
-- Made by: I_IBlackI_I (Blackstone#4953 on discord) for FactorioMMO
-- This module allows some more complex actions on the button in the top left, for example order them.

-- 
-- EXAMPLE USAGES CAN BE FOUND AT THE BOTTOM OF THIS FILE
--

--
--	VARIABLES
--

global.topgui = global.topgui or {}
global.topgui.raw = global.topgui.raw or {}
global.topgui.sorted = global.topgui.sorted or {}
global.topgui.style = mod_gui.button_style

--
--	FUNCTIONS
--

function topgui_add_button(player_name, button)
	if button.name ~= nil then
		local nb = {}
		if button.order ~= nil then
			nb.order = button.order
		else
			nb.order = 10
		end
		if button.type ~= nil then
			nb.type = button.type
		else
			nb.type = "button"
		end
		if nb.type == 'button' then
			if button.caption ~= nil then
				nb.caption = button.caption
			else
				nb.caption = "NO CAPTION"
			end
			if button.color ~= nil then
				nb.color = button.color
			else
				nb.color = {r = 1, g = 1, b = 1}
			end
		elseif nb.type == 'sprite-button' then
			if button.tooltip ~= nil then
				nb.tooltip = button.tooltip
			else
				nb.tooltip = ""
			end
			if button.sprite ~= nil then
				nb.sprite = button.sprite
			else
				nb.type = "button"
				nb.caption = "NO SPRITE"
				nb.tooltip = nil
			end
		end
		global.topgui.raw[player_name][button.name] = nb
		topgui_gui_changed(game.players[player_name])
	end
end

function topgui_remove_button(player_name, button_name)
	global.topgui.raw[player_name][button_name] = nil
	topgui_get_flow(game.players[player_name])[button_name].destroy()
end

function topgui_change_button_caption(player_name, button_name, caption)
	if global.topgui.raw[player_name][button_name].type == 'button' then
		global.topgui.raw[player_name][button_name].caption = caption
		topgui_get_flow(game.players[player_name])[button_name].caption = caption
	end
end

function topgui_change_button_color(player_name, button_name, color)
	if global.topgui.raw[player_name][button_name].type == 'button' then
		global.topgui.raw[player_name][button_name].color = color
		topgui_get_flow(game.players[player_name])[button_name].style.font_color = color
	end
end

function topgui_change_button_order(player_name, button_name, order)
	global.topgui.raw[player_name][button_name].order = order
	topgui_gui_changed(game.players[player_name])
end

function topgui_change_button_sprite(player_name, button_name, sprite)
	if global.topgui.raw[player_name][button_name].type == 'sprite-button' then
		global.topgui.raw[player_name][button_name].sprite = sprite
		topgui_get_flow(game.players[player_name])[button_name].sprite = sprite
	end
end

function topgui_gui_changed(p)
	topgui_sort_table(p)
	local tg = topgui_get_flow(p)
	tg.clear()
	for i, button in pairs(global.topgui.sorted[p.name]) do
		local b
		if button.type == "sprite-button" then
			b = tg.add {name=button.name, type="sprite-button", sprite=button.sprite, tooltip=button.tooltip}
		else 
			b = tg.add {name=button.name, type="button", caption=button.caption}
		end
		if button.color ~= nil then
			b.style.font_color = button.color
		end
	end
end

function topgui_sort_table(p)
	global.topgui.sorted[p.name] = {}
	for i, b in pairs(global.topgui.raw[p.name]) do
		local newtable
		if b.type == "sprite-button" then
			newtable = {name = i, order = b.order, type = b.type, sprite = b.sprite, tooltip = b.tooltip}
		else 
			newtable = {name = i, caption = b.caption, order = b.order, color = b.color, type = b.type}
		end
		table.insert(global.topgui.sorted[p.name], newtable)
	end
	table.sort(global.topgui.sorted[p.name], function(t1, t2)
			return t1.order < t2.order
		end)
	
end

function topgui_get_flow(p)
	local bf = mod_gui.get_button_flow(p)
	local tg
	if bf.topgui ~= nil then
		tg = bf.topgui
	else
		tg = bf.add {name = "topgui", type = "flow", direction = "horizontal", style = "slot_table_spacing_horizontal_flow"}
	end
	return tg
end
	
--
--	EVENTS
--

Event.register(defines.events.on_player_joined_game, function(event)
	local p = game.players[event.player_index]
	global.topgui.raw[p.name] = global.topgui.raw[p.name] or {}
	topgui_gui_changed(p)
end)

--
--	EXAMPLES
--

-- 			add a button, only name is required.

-- new_button = {name = "newbutton"}
-- topgui_add_button(p.name, new_button)

-- 			add a button, all possible values

-- new_button1 = {name = "newbutton1", caption = "I has caption!", order=1337, color={r = 1, g = 0, b = 1}}
-- topgui_add_button(game.player.name, new_button1)

-- 			add a sprite-button

-- new_sprite_button = {type="sprite-button", name = "newbutton1", sprite = "item/rocket-silo", order=1337, tooltip="Opens a menu"}
-- topgui_add_button(game.player.name, new_sprite_button)

-- 			remove a button

-- topgui_remove_button(p.name, new_button1)

--			change button values

-- topgui_change_button_order(p.name, "new_button1", 1)
-- Only buttons
-- topgui_change_button_caption(p.name, "new_button1", "Hello world!")
-- topgui_change_button_color(p.name, "new_button1", {r=0, g=1, b=0})
-- Only sprite-buttons
-- topgui_change_button_sprite(p.name, "new_button1", "item/rocket-silo")
-- topgui_change_button_tooltip(p.name, "new_button1", "Opens a menu!")



