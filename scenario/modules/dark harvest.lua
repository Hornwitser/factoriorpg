--Dark Harvest.  Only biters drop uranium.
--Written by Mylon
--MIT licensed

if MODULE_LIST then
	module_list_add("Dark Harvest")
end

harvest = {}

harvest.MULTIPLIER = 0.3

--Destroy any uranium, in case someone didn't change map gen settings
function harvest.despawn(event)
	local ores = event.surface.find_entities_filtered{name="uranium-ore", area=event.area}
	for each, ore in pairs(ores) do
		ore.destroy()
	end
end

function harvest.drop(event)
	if event.entity.force.name == "enemy" then
		if string.find(event.entity.name, "small") then
			harvest.reap(event, harvest.yield(1))
		elseif string.find(event.entity.name, "medium") then
			harvest.reap(event, harvest.yield(2))
		elseif string.find(event.entity.name, "big") then
			harvest.reap(event, harvest.yield(4))
		elseif string.find(event.entity.name, "behemoth") then
			harvest.reap(event, harvest.yield(8))
		elseif string.find(event.entity.name, "spawner") then
			if not global.harvest_spawn then
				global.harvest_spawn = {}
			end
			if not global.harvest_spawn[event.entity.surface.name] then
				global.harvest_spawn[event.entity.surface.name] = {}
			end
			table.insert(global.harvest_spawn[event.entity.surface.name], {position=event.entity.position, amount=harvest.yield(200)})
		end
	end
end

function harvest.reap(event, amount)
	if amount > 0 then
		event.entity.surface.spill_item_stack(event.entity.position, {name="uranium-ore", count=count}, true)
		--We'll assume force = player
		local force = game.forces.player
		force.item_production_statistics.on_flow("uranium-ore", amount)
	end
end

function harvest.yield(amount)
	local count = math.floor(amount * harvest.MULTIPLIER)
	if math.random() < ((amount * harvest.MULTIPLIER) % 1) then
		count = count + 1
	end
	return count
end

function harvest.prettifier()
	for k, v in pairs(game.surfaces) do
		if global.harvest_spawn and global.harvest_spawn[k] then
			for n, p in pairs(global.harvest_spawn[k]) do
				--harvest_reap(p.event, p.amount)
				v.spill_item_stack(p.position, {name="uranium-ore", count=p.amount}, true)
				--We'll assume force = player
				local force = game.forces.player
				force.item_production_statistics.on_flow("uranium-ore", amount)
			end
			global.harvest_spawn[k] = {}
		end
	end
end

Event.register(defines.events.on_chunk_generated, harvest.despawn)
Event.register(defines.events.on_entity_died, harvest.drop)
Event.register(defines.events.on_tick, harvest.prettifier)