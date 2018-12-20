--divOresity, version Dec 2018
--Written by Mylon
--MIT licensed
--Inspired by Ore Chaos

global.DIVERSITY_QUOTA = settings.global["diversity quota"].value
global.EXEMPT_AREA = settings.global["exempt area"].value
global.STONE_BYPRODUCT = settings.global["stone byproduct"].value
global.STONE_BYPRODUCT_RATIO = settings.global["stone byproduct ratio"].value
global.EXTRA_DIVORESITY = settings.global["extra divoresity"].value

--Build a table of potential ores to pick from.  Uranium is exempt from popping up randomly.
function divOresity_init()
	--Figure out the relative weight of ores.
	global.diverse_ores = {}
	global.extra_diverse_ores = {}
	local diverse_ore_ranking_raw = {}
	local extra_diverse_ore_ranking_raw = {}
    local ore_ranking = {}
	local diverse_ore_total = 0
	local extra_diverse_ore_total = 0
    
	for k,v in pairs(game.entity_prototypes) do
		if v.type == "resource"
		and v.resource_category == "basic-solid"
		and v.autoplace_specification then
		
			local autoplace = game.surfaces[1].map_gen_settings.autoplace_controls[v.name]
			local adding
			if autoplace then
				if autoplace.frequency == "none" then
					adding = 0
				elseif autoplace.frequency == "very-low" then
					adding = 1
				elseif autoplace.frequency == "low" then
					adding = 2
				elseif autoplace.frequency == "normal" then
					adding = 3
				elseif autoplace.frequency == "high" then
					adding = 4
				elseif autoplace.frequency == "very-high" then
					adding = 5
				end
			end
        	if not adding then adding = 3 end --failsafe
        	if adding > 0 then
				local amount = adding * game.entity_prototypes[v.name].autoplace_specification.coverage
				table.insert(extra_diverse_ore_ranking_raw, {name=v.name, amount=amount})
				extra_diverse_ore_ranking_raw = extra_diverse_ore_ranking_raw + amount
				if not game.entity_prototypes[v.name].mineable_properties.required_fluid then
					table.insert(diverse_ore_ranking_raw, {name=v.name, amount=amount})
					diverse_ore_total = diverse_ore_total + amount
				end
            end
        end
    end

    --Debug
    --log(serpent.block(diverse_ore_ranking_raw))

    --Calculate ore distribution from 0 to 1.
    local last_key = 0
    --local ore_ranking_size = 0 --Essentially #ore_ranking_raw
    for k,v in pairs(diverse_ore_ranking_raw) do
        local key = last_key + v.amount / diverse_ore_total
        last_key = key

        --if key == 1 then key = 0.9999999 end
        --ore_ranking[key] = v.name
        table.insert(global.diverse_ores, {v.name, key})
        --ore_ranking_size = ore_ranking_size + 1
        --Debug
        --log("Ore: " .. v.name .. " portion: " .. key)
        --According to this, at this stage, uranium should be 2% of all ore.
	end

	for k,v in pairs(extra_diverse_ore_ranking_raw) do
        local key = last_key + v.amount / extra_diverse_ore_total
        last_key = key

        --if key == 1 then key = 0.9999999 end
        --ore_ranking[key] = v.name
        table.insert(global.extra_diverse_ores, {v.name, key})
        --ore_ranking_size = ore_ranking_size + 1
        --Debug
        --log("Ore: " .. v.name .. " portion: " .. key)
        --According to this, at this stage, uranium should be 2% of all ore.
    end

	-- global.diverse_ores = {}
	-- global.extra_diverse_ores = {}
	-- for k,v in pairs(game.entity_prototypes) do
	-- 	if v.type == "resource"
	-- 	and v.resource_category == "basic-solid"
	-- 	and v.autoplace_specification then
	-- 		table.insert(global.extra_diverse_ores, v.name)
	-- 		if v.mineable_properties.required_fluid == nil then
	-- 			table.insert(global.diverse_ores, v.name)
	-- 		end
	-- 	end
	-- end
end

function get_type(table)
	if #table == 0 then
		--Something went wrong!
		log("No ores to choose from.")
		return
	end
	local random = math.random()
	for _, ore in pairs(table) do
		if ore[2] > random then
			return ore[1]
		end
	end
	--Still here?  Return the last entry in the table
	return(table[#table][1])
end

function richness_correction_factor(old, new)
	local old_richness = game.surfaces[1].map_gen_settings.autoplace_controls[old].richness
	local new_richness = game.surfaces[1].map_gen_settings.autoplace_controls[new].richness

	local function convert(text)
		if text == "very-low" then return 1 end
		if text == "low" then return 3 end
		if text == "normal" then return 5 end
		if text == "high" then return 7 end
		if text == "very-high" then return 9 end
		--Failsafe
		return 5
	end

	--Debug
	--log(old_richness .. ":" .. convert(old_richness))

	return (convert(new_richness) / convert(old_richness))
end

function diversify(event)
	local ores = event.surface.find_entities_filtered{type="resource", area=event.area}
	for k,v in pairs(ores) do
		if math.abs(v.position.x) > global.EXEMPT_AREA or math.abs(v.position.y) > global.EXEMPT_AREA then
			if v.prototype.resource_category == "basic-solid" then
				local random = math.random()
				if v.name == "stone" and global.STONE_BYPRODUCT then
					v.destroy()
				elseif random < global.DIVERSITY_QUOTA then --Replace!
					local refugee
					local correction_factor = 1
					if v.prototype.mineable_properties.required_fluid and global.EXTRA_DIVORESITY then
						refugee = get_type(global.extra_diverse_ores)
					else
						refugee = get_type(global.diverse_ores)
					end
					correction_factor = richness_correction_factor(v.name, refugee)
					event.surface.create_entity{name=refugee, position=v.position, amount=v.amount * correction_factor}
					v.destroy()
				elseif global.STONE_BYPRODUCT and random < global.STONE_BYPRODUCT_RATIO then --Replace with stone!
					event.surface.create_entity{name="stone", position=v.position, amount=v.amount}
					v.destroy()
				end
			end
		end
	end
end

script.on_event(defines.events.on_chunk_generated, diversify)
script.on_init(divOresity_init)
script.on_configuration_changed(divOresity_init)
