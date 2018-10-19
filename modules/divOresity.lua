--divOresity
--Written by Mylon
--MIT licensed
--Inspired by Ore Chaos

global.DIVERSITY_QUOTA = settings.global["diversity quota"].value
global.EXEMPT_AREA = settings.global["exempt area"].value
global.STONE_BYPRODUCT = settings.global["stone byproduct"].value
global.STONE_BYPRODUCT_RATIO = settings.global["stone byproduct ratio"].value

EXTRA_DIVORESITY = true

--Build a table of potential ores to pick from.  Uranium is exempt from popping up randomly.
function divOresity_init()
	global.diverse_ores = {}
	global.extra_diverse_ores = {}
	for k,v in pairs(game.entity_prototypes) do
		if v.type == "resource"
		and v.resource_category == "basic-solid"
		and v.autoplace_specification then
			table.insert(global.extra_diverse_ores, v.name)
			if v.mineable_properties.required_fluid == nil then
				table.insert(global.diverse_ores, v.name)
			end
		end
	end
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
					if v.prototype.mineable_properties.required_fluid and EXTRA_DIVORESITY then
						refugee = global.extra_diverse_ores[math.random(#global.extra_diverse_ores)]
					else
						refugee = global.diverse_ores[math.random(#global.diverse_ores)]
					end
					event.surface.create_entity{name=refugee, position=v.position, amount=v.amount}
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
