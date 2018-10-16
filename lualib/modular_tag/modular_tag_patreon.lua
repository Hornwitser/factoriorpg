-- Give patreons the option to set their patreon tag
-- A 3Ra Gaming Idea
-- Made by I_IBlackI_I

global.modular_tag_patreon = global.modular_tag_patreon or {}
global.modular_tag_patreon.patreons = {
		{name = "I_IBlackI_I", tag = "Lua Hero", color = {r=1.0,g=1.0,b=1.0}, chat_color = nil},
		{name = "psihius", tag = "SysAdmin", color = nil, chat_color = nil},
		{name = "Hornwitser", tag = "MoneyBags", color = nil, chat_color = nil},
		{name = "jordank321", tag = "I'm not sure LMAO", color = nil, chat_color = nil},
		{name = "viceroypenguin", tag = "MoneyBags", color = nil, chat_color = nil},
		{name = "sikian", tag = "Sikjizz!", color = nil, chat_color = nil},
		{name = "Lyfe", tag = "Is Alive", color = { r = 0.559, g = 0.761, b = 0.157}, chat_color = { r = 0.708, g = 0.996, b = 0.134}},
		{name = "sniperczar", tag = "Behemoth Bait", color = nil, chat_color = nil},
		{name = "i-l-i", tag = "Space Dolphin", color = nil, chat_color = nil},
		{name = "Uriopass", tag = "Ratio Maniac", color = nil, chat_color = nil},
		{name = "audigex", tag = "Spaghetti Monster", color = nil, chat_color = nil},
		{name = "Sergeant_Steve", tag = "Biter Killer", color = { r = 0.0, g = 0.0, b = 1.0}, chat_color = { r = 0.35, g = 0.4, b = 1.0}},
		{name = "Zr4g0n", tag = "Totally not a dragon!", color = { r = 0.227, g = 0.263, b = 0.639}, chat_color = { r = 0.455, g = 0.506, b = 0.871}},
		{name = "LordKiwi", tag = nil, color = nil, chat_color = nil},
		{name = "stik", tag = nil, color = nil, chat_color = nil},
		{name = "Zirr", tag = nil, color = nil, chat_color = nil},
		{name = "Nr42", tag = nil, color = nil, chat_color = nil},
		{name = "zerot", tag = nil, color = nil, chat_color = nil},
		{name = "tzwaan", tag = "Educated Smartass", color = { r = 0.275, g = 0.755, b = 0.712}, chat_color = { r = 0.335, g = 0.918, b = 0.866}},
		{name = "Lazyboy38", tag = "Lazy German", color = nil, chat_color = nil},
		{name = "Blooper", tag = "Reliability Engineer", color = nil, chat_color = nil},
		{name = "exi2163", tag = "Solution Engineer", color = nil, chat_color = nil},
		{name = "Kodikuu", tag = "Tinkerer", color = { r = 0.404, g = 0.227, b = 0.718}, chat_color = nil},
		{name = "Twinsen", tag = "Factorio Developer", color = nil, chat_color = nil},
		{name = "SpennyDurp", tag = "I WILL Break It", color = nil, chat_color = nil},
		{name = "Alkumist", tag = "Snoot booper :3", color = { r = 1.0, g = 1.0, b = 0.0}, chat_color = nil}
}

function modular_tag_patreon_on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local player = game.players[event.element.player_index]
	local p = player
	local name = event.element.name
	if (name == "modular_tag_patreon_button") then
		player.tag = "[Patreon]"
	end
	if (name == "modular_tag_patreon_unique_button") then
		for i, patreon in pairs(global.modular_tag_patreon.patreons) do
			if(player.name == patreon.name) then
				if(patreon.tag ~= nil) then
					player.tag = "[" .. patreon.tag .. "]"
					player.print("Your unique tag has been applied!")
				else 
					player.print("O.o It seems you don't have a unique tag.. Please contact the admins to get one.")
				end
				if(patreon.color ~= nil) then
					player.color = patreon.color
					player.print("Your unique color has been applied!")
				else 
					player.print("o.O It seems you don't have a unique player-color.. Please contact the admins to get one.")
				end
				if(patreon.color ~= nil) then
					player.chat_color = patreon.chat_color
					player.print("Your unique text-color has been applied!")
				end
			end
		end
	end
end

function modular_tag_patreon_create_gui(p)
	local mtgf = modular_tag_get_frame(p)
	local mtf
		if mtgf.modular_tag_patreon_flow ~= nil and mtgf.modular_tag_patreon_flow.valid then
		mtf = mtgf.modular_tag_patreon_flow
	else
		mtf = mtgf.add {type = "flow", direction = "vertical", name = "modular_tag_patreon_flow", style = "slot_table_spacing_vertical_flow"}
	end
	if mtf.modular_tag_patreon_unique_button ~= nil and mtf.modular_tag_patreon_unique_button.valid then
	
	else
		local b2 = mtf.add {type = "button", name = "modular_tag_patreon_unique_button", caption = "Unique"}
		b2.style.font_color = {r=0.1, g=0.9, b=0.1}
		b2.style.minimal_width = 155
	end
	if mtf.modular_tag_patreon_button ~= nil and mtf.modular_tag_patreon_button.valid then
	
	else
		local b1 = mtf.add { type = "button", caption = "Patreon", name = "modular_tag_patreon_button" }
		b1.style.font_color = {r=0.2, g=0.7, b=1}
		b1.style.minimal_width = 155
	end
end

function modular_tag_patreon_check(player)
	for _, patreon in pairs(global.modular_tag_patreon.patreons) do
		if(player.name == patreon.name) then
			return true
		end
	end
	return false
end

function modular_tag_patreon_joined(event)
	local player = game.players[event.player_index]
	if(modular_tag_patreon_check(player)) then
		modular_tag_patreon_create_gui(player)
	end
	for i, patreon in pairs(global.modular_tag_patreon.patreons) do
		if(player.name == patreon.name) then
			if(patreon.tag ~= nil) then
				player.tag = "[" .. patreon.tag .. "]"
				player.print("Unique tag applied automagically!")
			else 
				player.print("O.o It seems you don't have a unique tag.. Please contact the admins to get one.")
			end
			if(patreon.color ~= nil) then
				player.color = patreon.color
				player.print("Unique color applied automagically!")
			else 
				player.print("o.O It seems you don't have a unique color.. Please contact the admins to get one.")
			end
			if(patreon.chat_color ~= nil) then
				player.chat_color = patreon.chat_color
				player.print("Unique chat-color applied automagically!")
			end
		end
	end
end

Event.register(defines.events.on_gui_click, modular_tag_patreon_on_gui_click)
Event.register(defines.events.on_player_joined_game, modular_tag_patreon_joined)
