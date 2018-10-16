-- TOOLS: Recommend all be turned on


require "lualib/event"
require "mod-gui" --required for all other modules

require "lualib/topgui" --utility module to be able to order the buttons in the top left
require "lualib/char_mod"	--utility module to prevent multiple modules conflicting when modifying player bonus
require "lualib/bot"	--3ra shit
require "announcements"	--Module to announce stuff ingame / give the players a welcome message
--require "rocket" --Module to stop people removing the rocket silo
--require "gravemarker" --Create a map tag on player death for easier corpse finding
require "lualib/modular_tag/modular_tag" --Module to let players set a tag behind their names to improve teamwork, also allows other modules to get (and use) its canvas.
require "lualib/modular_admin/modular_admin" --New admin tools
require "lualib/modular_information/modular_information" --New player information system
require "lualib/antigrief" --untested
require "equipment"

require "lualib/pdnc" --Zr's fancy day-night cycle stuff
-- require "wg_jungle" --Jungle World Generator, generates a world full of trees!

require "debug"


