--Infinite ores, by Mylon
--Intended for Very High frequency, very small size.

if MODULE_LIST then
	module_list_add("Infinite Ores")
end

local INFINITE = 999999999

function infinify(event)
	local ores = event.surface.find_entities_filtered{type="resource", area=event.area}
	for k,v in pairs(ores) do
		if v.prototype.resource_category == "basic-solid" then
			v.amount = INFINITE
		end
	end
end

Event.register(defines.events.on_chunk_generated, infinify)