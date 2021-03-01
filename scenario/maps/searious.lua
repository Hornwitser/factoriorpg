--Searious map-mod.
--Written by Mylon
--MIT license
--2017

require "utils/perlin"

SEARIOUS_STARTING_RADIUS = 100

if MODULE_LIST then
	module_list_add("Searious")
end

--Create a 32x32 table and set a flag if ore is nearby.  Then turn everything not flagged to water.
function sea_the_world(event)
    --Create a 2d array.  This will auto-create our y table if x does not exist, allowing flood[x][y] = true to just work
    local flood = setmetatable({}, { __index = function(t, k) t[k] = {} return t[k] end })

    local tiles = {}

    local ltx = event.area.left_top.x
    local lty = event.area.left_top.y
    local rbx = event.area.right_bottom.x
    local rby = event.area.right_bottom.y

    --Check starting area
    --Check existing water and ignore if true
    for x = ltx-1, rbx+1 do
        for y = lty-1, rby+1 do
            if x^2 + y^2 > SEARIOUS_STARTING_RADIUS^2 then
                -- Need to add a special check to avoid drawing lines on the edges.
                --if not event.surface.get_tile(x, y).collides_with("water-tile") then --and x >= ltx and x < rbx and y >= lty and y < rby then
                --     table.insert(tiles, {name="deepwater", position={x,y}})
                -- else
                    flood[x][y] = true
                --end
            end
        end
    end

    --Check ore.
    local ores = event.surface.find_entities_filtered{type="resource", area=event.area}
	for k,v in pairs(ores) do
        for x = math.floor(v.position.x) - 1, math.floor(v.position.x) + 1 do
            for y = math.floor(v.position.y) - 1, math.floor(v.position.y) + 1 do
                flood[x][y] = false
            end
        end
    end

    --Now build tile table
    for x = ltx, rbx do
        for y = lty, rby do
            if (flood[x][y]) then
                local type = "water"
                local noise = perlin.noise(x, y)
                if noise > 0.2 then
                    type = "deepwater"
                elseif noise < -0.8 then
                    type = "water-green"
                elseif noise < -0.6 then
                    type = "grass-1"                  
                end
                table.insert(tiles, {name=type, position={x,y}})
            end
        end
    end

    --Finally set
    event.surface.set_tiles(tiles, true)
end

Event.register(defines.events.on_chunk_generated, sea_the_world)
