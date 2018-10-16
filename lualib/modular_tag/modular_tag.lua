-- Give players the option to set their preferred role as a tag
-- Modified by I_IBlackI_I

global.modular_tag = global.modular_tag or {}

global.modular_tag.use_sprite_button_open = true
global.modular_tag.use_sprite_button_close = false
global.modular_tag.sprite_button_open_sprite = "utility/side_menu_achievements_icon"
global.modular_tag.sprite_button_close_sprite = "utility/side_menu_achievements_icon"
global.modular_tag.sprite_button_open_tooltip = "Open tag menu"
global.modular_tag.sprite_button_close_tooltip = "Close tag menu"
global.modular_tag.button_open_caption = "Open Tag"
global.modular_tag.button_close_caption = "Close Tag"




global.modular_tag.visible = global.modular_tag.visible or {}

require "modular_tag_patreon"

-- Tag list
global.modular_tag.tags = {
	{ display_name = "Clear", color = {r=1,g=0,b=0} },
	{ display_name = "Mining" },
	{ display_name = "Lumberjack" },
	{ display_name = "Fishing" },
	{ display_name = "Oil" },
	{ display_name = "Bus" },
	{ display_name = "Smelting" },
	{ display_name = "Pest Control" },
	{ display_name = "Automation" },
	{ display_name = "Quality Control" },
	{ display_name = "Power" },
	{ display_name = "Lights" },
	{ display_name = "Trains" },
	{ display_name = "Science" },
	{ display_name = "Robotics"},
	{ display_name = "AFK" }
}

function modular_tag_create_gui(event)
	local player = game.players[event.player_index]
	local p = player
	global.modular_tag.visible[p.name] = global.modular_tag.visible[p.name] or false
	if global.modular_tag.visible[p.name] then
		if global.modular_tag.use_sprite_button_close then
			topgui_add_button(p.name, {type="sprite-button", name = "modular_tag_toggle_button", sprite = global.modular_tag.sprite_button_close_sprite, tooltip=global.modular_tag.sprite_button_close_tooltip})
		else 
			topgui_add_button(p.name, {name = "modular_tag_toggle_button", caption = global.modular_tag.button_close_caption, color = {r=1, g=0, b=0}})
		end
	else
		if global.modular_tag.use_sprite_button_open then
			topgui_add_button(p.name, {type="sprite-button", name = "modular_tag_toggle_button", sprite = global.modular_tag.sprite_button_open_sprite, tooltip=global.modular_tag.sprite_button_open_tooltip})
		else 
			topgui_add_button(p.name, {name = "modular_tag_toggle_button", caption = global.modular_tag.button_open_caption, color = {r=0, g=1, b=0}})
		end
	end
	modular_tag_update_gui(player)
end


function modular_tag_toggle_gui_visibility(player)
	if global.modular_tag.visible[player.name] then
		if global.modular_tag.use_sprite_button_open then
			topgui_add_button(player.name, {type="sprite-button", name = "modular_tag_toggle_button", sprite = global.modular_tag.sprite_button_open_sprite, tooltip=global.modular_tag.sprite_button_open_tooltip})
		else 
			topgui_add_button(player.name, {name = "modular_tag_toggle_button", caption = global.modular_tag.button_open_caption, color = {r=0, g=1, b=0}})
		end
		global.modular_tag.visible[player.name] = false
	else
		if global.modular_tag.use_sprite_button_close then
			topgui_add_button(player.name, {type="sprite-button", name = "modular_tag_toggle_button", sprite = global.modular_tag.sprite_button_close_sprite, tooltip=global.modular_tag.sprite_button_close_tooltip})
		else 
			topgui_add_button(player.name, {name = "modular_tag_toggle_button", caption = global.modular_tag.button_close_caption, color = {r=1, g=0, b=0}})
		end
		global.modular_tag.visible[player.name] = true
	end
	modular_tag_get_frame(player).style.visible = global.modular_tag.visible[player.name]
end

function modular_tag_update_gui(player)
	local tfl = modular_tag_get_flow(player)
	tfl.clear()
	for _, role in pairs(global.modular_tag.tags) do
		local b = tfl.add { type = "button", caption = role.display_name, name = "modular_tag_" .. role.display_name }
		if (role.color ~= nil) then
			b.style.font_color = role.color
			b.style.hovered_font_color = {r=0.8,g=0.8,b=0.8}
		end
		b.style.minimal_width = 130
	end
end

function modular_tag_get_frame(player)
	local ff = mod_gui.get_frame_flow(player)
	local tag_frame = ff["modular_tag-frame"]
	local tf
	if(tag_frame ~= nil) then
		tf = tag_frame
	else
		tf = ff.add { type = "frame", name = "modular_tag-frame", caption = "Choose Tag", direction = "vertical"}
		local v = global.modular_tag.visible[player.name] or false
		tf.style.visible = v
		tf.style.maximal_width = 180
	end
	return tf
end

function modular_tag_get_flow(player)
	local tf = modular_tag_get_frame(player)
	local tag_scroll = tf["modular_tag-panel-scroll"]
	local ts
	if(tag_scroll ~= nil) then
		ts = tag_scroll
	else
		ts = tf.add { type = "scroll-pane", name = "modular_tag-panel-scroll"}
		ts.style.maximal_height = 250
	end	
	local tag_flow = ts["modular_tag-panel-scroll-flow"]
	local tfl
	if(tag_flow ~= nil) then
		tfl = tag_flow
	else
		tfl = ts.add { type = "flow", direction = "vertical", name = "modular_tag-panel-scroll-flow", style = "slot_table_spacing_vertical_flow"}
	end
	return tfl
end

function modular_tag_on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local player = game.players[event.element.player_index]
	local p = player
	local name = event.element.name
	if (name == "modular_tag_toggle_button") then
		modular_tag_toggle_gui_visibility(player)
	end
	if (name == "modular_tag_Clear") then
		player.tag = ""
		return
	end
	
	for _, role in pairs(global.modular_tag.tags) do
		if (name == "modular_tag_" .. role.display_name) then
			player.tag = "[" .. role.display_name .. "]"
		end
	end
	
end


Event.register(defines.events.on_gui_click, modular_tag_on_gui_click)
Event.register(defines.events.on_player_joined_game, modular_tag_create_gui)



