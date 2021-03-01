-- Give players the option to set their preferred role as a tag
-- A 3Ra Gaming creation
-- Modified by I_IBlackI_I
-- Tag list modified by Mylon

if MODULE_LIST then
	module_list_add("Tags")
end

function tag_create_gui(event)
	local player = game.players[event.player_index]
	if not mod_gui.get_button_flow(player)["tag-button"] then
		mod_gui.get_button_flow(player).add { name = "tag-button", type = "sprite-button", sprite = "item/blueprint-book", tooltip = "Set a tag" }
	end
end

-- Tag list
global.tag = global.tag or {}
global.tag.tags = {
	{ display_name = "Mining" },
	{ display_name = "Smelting" },
	{ display_name = "Oil" },
	{ display_name = "Pest Control" },
	{ display_name = "Automation" },
	{ display_name = "Quality Control" },
	{ display_name = "Power" },
	{ display_name = "Trains" },
	{ display_name = "Science" },
	{ display_name = "AFK" },
	{ display_name = "Clear" }
}

function tag_expand_gui(player)
	local frame = mod_gui.get_frame_flow(player)["tag-panel"]
	if (frame) then
		frame.destroy()
	else
		local frame = mod_gui.get_frame_flow(player).add { type = "frame", name = "tag-panel", caption = "Choose Tag"}
		local scroll = frame.add { type = "scroll-pane", name = "tag-panel-scroll"}
		scroll.style.maximal_height = 250
		local list = scroll.add { name="tag_table", type = "table", column_count = 1}
		for _, role in pairs(global.tag.tags) do
			list.add { type = "button", caption = role.display_name, name = "tag_" .. role.display_name }
		end
		if player.name == "SortaN3W" then
			list.add { type = "button", caption = "Mylon's Favorite Slave", name = "tag_" .. "Mylon's Favorite Slave" }
		end
	end
end

function tag_on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local player = game.players[event.element.player_index]
	local name = event.element.name
	if (name == "tag-button") then
		tag_expand_gui(player)
	end

	if (name == "tag_Clear") then
		player.tag = ""
		tag_expand_gui(player)
		return
	end
	
	if string.find(event.element.name, "tag_") then
		player.tag = "[" .. event.element.caption .. "]"
		tag_expand_gui(player)
	end
end

commands.add_command("tag", "Set a custom tag.", function(tag)
	if tag.parameter then
		--game.print(serpent.line(tag))
		game.players[tag.player_index].tag = "[" .. tag.parameter .. "]"
		game.players[tag.player_index].print("Tag set.")
	else
		game.player.tag = ""
		game.player.print("Tag cleared.")
	end
end)

if rpg then
	Event.register(rpg.on_rpg_gui_created, tag_create_gui)
else
	Event.register(defines.events.on_player_created, tag_create_gui)
end
Event.register(defines.events.on_gui_click, tag_on_gui_click)
