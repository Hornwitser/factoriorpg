--Blue print mirror.  yoinked from WoG Base on Dec 2017
--Adapted for use as a command by Mylon

if MODULE_LIST then
	module_list_add("Blueprint Mirror")
end

bpmirror = {}

commands.add_command("bpmirror", "Mirror the BP on the cursor.  Use bpmirror h or bpmirror v to flip horizontally or vertically.  Default option is hozontally", function(params)
    if not game.player then return end --In case the server tries to run this.
    if params.parameter == nil or params.parameter == "h" then
        bpmirror.bpflip_h(game.player)
    elseif params.parameter == "v" then
        bpmirror.bpflip_v(game.player)
    else
        game.player.print("Invalid argument given.  Use option h or v, or none at all to default to h.")
    end
end)

function bpmirror.bpflip_v(player)
	local cursor = bpmirror.getBlueprintCursorStack(player)
	local ents = {}
	if cursor then
		if cursor.get_blueprint_entities() ~= nil then
			ents = cursor.get_blueprint_entities()
			for i = 1, #ents do
				local dir = ents[i].direction or 0
				if ents[i].name == "curved-rail" then
					ents[i].direction = (13 - dir)%8
				elseif ents[i].name == "storage-tank" then
					if ents[i].direction == 2 or ents[i].direction == 6 then
						ents[i].direction = 4
					else
						ents[i].direction = 2
					end
				elseif ents[i].name == "rail-signal" or ents[i].name == "rail-chain-signal" then
					if dir == 1 then
						ents[i].direction = 7
					elseif  dir == 2 then
						ents[i].direction = 6
					elseif  dir == 3 then
						ents[i].direction = 5
					elseif  dir == 5 then
						ents[i].direction = 3
					elseif  dir == 6 then
						ents[i].direction = 2
					elseif  dir == 7 then
						ents[i].direction = 1
					end
				elseif ents[i].name == "train-stop" then
					if dir == 2 then
						ents[i].direction = 6
					elseif  dir == 6 then
						ents[i].direction = 2
					end
				else
					ents[i].direction = (12 - dir)%8
				end
				ents[i].position.y = -ents[i].position.y
				if ents[i].drop_position then
					ents[i].drop_position.y = -ents[i].drop_position.y
				end
				if ents[i].pickup_position then
					ents[i].pickup_position.y = -ents[i].pickup_position.y
				end
			end
			cursor.set_blueprint_entities(ents)
		end
		if cursor.get_blueprint_tiles() ~= nil then
			ents = cursor.get_blueprint_tiles()
			for i = 1, #ents do
				local dir = ents[i].direction or 0
				ents[i].direction = (12 - dir)%8
				ents[i].position.y = -ents[i].position.y
			end
			cursor.set_blueprint_tiles(ents)
		end
    player.print("Blueprint mirrored successfully.")
  else
    player.print("No Blueprint in cursor or Blueprint still in book - Remove Blueprint from Book then mirror it then you can return it to Book.")
	end
end

function bpmirror.bpflip_h(player)
	local cursor = bpmirror.getBlueprintCursorStack(player)
	local ents = {}
	if cursor then
		if cursor.get_blueprint_entities() ~= nil then
			ents = cursor.get_blueprint_entities()
			for i = 1, #ents do
				local dir = ents[i].direction or 0
				if ents[i].name == "curved-rail" then
					ents[i].direction = (9 - dir)%8
				elseif ents[i].name == "storage-tank" then
					if ents[i].direction == 2 or ents[i].direction == 6 then
						ents[i].direction = 4
					else
						ents[i].direction = 2
					end
				elseif ents[i].name == "rail-signal" or ents[i].name == "rail-chain-signal" then
					--player.print("1. " .. ents[i].name .. ": " .. dir)
					if dir == 0 then
						ents[i].direction = 4
					elseif  dir == 1 then
						ents[i].direction = 3
					elseif  dir == 3 then
						ents[i].direction = 1
					elseif  dir == 4 then
						ents[i].direction = 0
					elseif  dir == 5 then
						ents[i].direction = 7
					elseif  dir == 7 then
						ents[i].direction = 5
					end
					--player.print("2. " .. ents[i].name .. ": " .. ents[i].direction)
				elseif ents[i].name == "train-stop" then
					--player.print("1. " .. ents[i].name .. ": " .. dir)
					if dir == 0 then
						ents[i].direction = 4
					elseif  dir == 4 then
						ents[i].direction = 0
					end
					--player.print("2. " .. ents[i].name .. ": " .. ents[i].direction)
				else
					ents[i].direction = (16 - dir)%8
				end
				ents[i].position.x = -ents[i].position.x
				if ents[i].drop_position then
					ents[i].drop_position.x = -ents[i].drop_position.x
				end
				if ents[i].pickup_position then
					ents[i].pickup_position.x = -ents[i].pickup_position.x
				end
			end
			cursor.set_blueprint_entities(ents)
		end
		if cursor.get_blueprint_tiles() ~= nil then
			ents = cursor.get_blueprint_tiles()
			for i = 1, #ents do
				local dir = ents[i].direction or 0
				ents[i].direction = (16 - dir)%8
				ents[i].position.x = -ents[i].position.x
			end
			cursor.set_blueprint_tiles(ents)
		end
    player.print("Blueprint mirrored successfully.")
  else
    player.print("No Blueprint in cursor or Blueprint still in book - Remove Blueprint from Book then mirror it then you can return it to Book.")
	end
end

function bpmirror.getBlueprintCursorStack(player)
	local cursor = player.cursor_stack
	if cursor.valid_for_read and cursor.name == "blueprint" and cursor.is_blueprint_setup() then
		return cursor
  end          
	return nil
end
