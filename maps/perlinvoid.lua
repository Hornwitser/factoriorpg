require "utils/perlin"

function perlin_void(event)
    local tiles = {}
    for x = event.area.left_top.x, event.area.right_bottom.x do
        for y = event.area.left_top.y, event.area.right_bottom.y do
            if perlin.noise(x,y) < -0.1 then --Less than or greater than 0 means most of the area will be connected.
                table.insert(tiles, {name="out-of-map", position={x,y}})
            end
        end
    end
    event.surface.set_tiles(tiles)
end

Event.register(defines.events.on_chunk_generated, perlin_void)
