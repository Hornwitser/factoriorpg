--tOre du Monde by Mylon, 2017
--Alternate titles: Six degrees of sepOreation, cardOrenal
--Each type of ore only spawns in one direction on the map

tOre = {STARTING_AREA = 200,
    SLICE = math.pi / 3,
    ORDER = {"copper-ore", "stone", "crude-oil", "iron-ore", "uranium-ore", "coal"} --iron and copper are opposed.  oil and coal are opposed.  Other than these rules, I might random this order
}

if MODULE_LIST then
	module_list_add("tOre du Monde")
end

function tOre.spin()
    global.tOre = {offset = math.random() * 2 * math.pi + math.pi} --Rotate the map generation by some random angle.  +math.pi to keep it positive because atan2 is [-2*pi, 2*pi]
end

function tOre.challenge(event)
    local ores = event.surface.find_entities_filtered{type="resource", area=event.area}
	for k,v in pairs(ores) do
        --if not (v.prototype.resource_category == "basic-fluid") and not (v.name == "uranium-ore") then
         if v.position.y^2 + v.position.x^2 > tOre.STARTING_AREA^2 then
            local slice = math.floor( ((math.atan2(v.position.y, v.position.x) + global.tOre.offset) % (2 * math.pi) ) / tOre.SLICE ) + 1
            if slice >= 7 then
                log("tOre error: Slice out of bounds.")
                return
            end
            if v.name ~= tOre.ORDER[slice] then
                v.destroy()
            end
        end
    end
end

Event.register(defines.events.on_chunk_generated, tOre.challenge)
Event.register(-1, tOre.spin)